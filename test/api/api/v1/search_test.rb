require 'test_helper'

class API::V1::SearchTest < APITest
  test 'GET /api/search requires an API key' do
    get '/api/v1/search'
    assert_equal 401, last_response.status
  end

  test 'GET /api/search works with search role' do
    set_api_key(api_keys(:api_search))
    get '/api/v1/search'
    assert last_response.ok?
  end

  test 'GET /api/search works with admin role' do
    set_api_key
    get '/api/v1/search'
    assert last_response.ok?
  end

  test 'GET /api/search/?q= performs a full text search' do
    set_api_key
    import_docs
    get '/api/v1/search', q: 'algebra'
    assert_equal 1, last_json['documents'].size
    assert_match (/algebra/i), last_json['documents'].first['title']
  end

  test 'GET /api/search/?title= performs a full text search' do
    set_api_key
    import_docs
    get '/api/v1/search', title: 'algebra'
    assert_equal 1, last_json['documents'].size
    assert_match (/algebra/i), last_json['documents'].first['title']
  end

  test 'GET /api/search/?description= performs a full text search' do
    set_api_key
    import_docs
    get '/api/v1/search', description: 'algebra'
    assert_equal 1, last_json['documents'].size
    assert_match (/algebra/i), last_json['documents'].first['description']
  end

  test 'GET /api/search/?grade_ids= finds docs with specified grade' do
    set_api_key
    import_docs
    grade = repositories(:api_docs).documents.first.grades.first

    get '/api/v1/search', grade_ids: [grade.id]

    assert_equal 1, last_json['documents'].size
    assert last_json['documents'].first['grades'].any? { |g| g['id'] == grade.id }
  end

  test 'GET /api/search/?grade_name= finds docs with specified grade' do
    set_api_key
    import_docs

    get '/api/v1/search', grade_name: 'grade 1'

    assert_equal 1, last_json['documents'].size
    assert last_json['documents'].first['grades'].any? { |g| g['name'] == 'Grade 1' }
  end

  test 'GET /api/search/?identity_name=& finds docs with idt name' do
    set_api_key
    import_docs

    get '/api/v1/search', identity_name: 'algebraguys'

    assert_equal 1, last_json['documents'].size
    assert last_json['documents'].first['identities'][0]['name'] == 'AlgebraGuys'
  end

  test 'GET /api/search/?identity_name=& finds docs with idt type' do
    set_api_key
    import_docs

    get '/api/v1/search', identity_type: 'publisher'

    assert_equal 2, last_json['documents'].size
    assert last_json['documents'].first['identities'].all? { |idt| idt['type'] == 'publisher' }
  end

  test 'GET /api/search/?identity_name=&identity_type finds docs with idt name & type' do
    set_api_key
    import_docs

    get '/api/v1/search', identity_name: 'algebraguys', identity_type: 'publisher'

    assert_equal 1, last_json['documents'].size
    idt = last_json['documents'].first['identities'][0]
    assert_equal 'publisher', idt['type']
    assert_equal 'AlgebraGuys', idt['name']
  end

  test 'GET /api/search/?repository_ids filters by repo' do
    set_api_key
    create_repo

    get '/api/v1/search', repository_ids: [@repo.id]

    assert_equal 1, last_json['documents'].size
    assert_equal 'New doc', last_json['documents'].first['title']
    assert_equal 'New doc', last_json['documents'].first['description']
  end

  def create_repo
    @repo = Repository.create!(
      organization: organizations(:api_user),
      name: 'New repo',
      public: false
    )
    @repo.create_search_index!

    @doc = @repo.documents.create!(
      title: 'New doc',
      description: 'New doc',
      document_status: DocumentStatus.published,
      url: Url.find_or_create_by!(url: 'http://www.cooldocs.com')
    )
    @doc.index_document

    refresh_indices
  end

  def import_docs
    delete_indices

    DocumentImport.create!(
      repository: repositories(:api_docs),
      file: File.new(File.join(fixture_path, 'document_import', 'api_docs.csv'))
    ).process

    repositories(:api_docs).index_all_documents

    refresh_indices
  end
end
