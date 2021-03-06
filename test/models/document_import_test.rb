require 'test_helper'

class DocumentImportTest < ActiveSupport::TestCase
  setup do
    @khan_csv  = File.new(File.join(fixture_path, 'document_import', 'khan_new_docs.csv'))
    @khan_repo = repositories(:khan)
  end

  test '#prepare_import creates doc import rows for the CSV rows' do
    doc_import = DocumentImport.create!(repository: @khan_repo, file: @khan_csv)

    doc_import.prepare_import

    refute_nil      doc_import.prepared_at
    assert_equal 2, doc_import.rows.size
  end

  test '#create_mappings maps the content for each doc import row' do
    doc_import = DocumentImport.create!(repository: @khan_repo, file: @khan_csv)

    doc_import.prepare_import
    doc_import.create_mappings

    refute_nil doc_import.mapped_at
    assert     doc_import.rows.all?(&:mappings)
  end

  test '#import converts doc import rows into documents' do
    doc_import = DocumentImport.create!(repository: @khan_repo, file: @khan_csv)

    doc_import.prepare_import
    doc_import.create_mappings

    assert_difference 'Document.count', +2 do
      doc_import.import
    end

    refute_nil doc_import.imported_at
  end

  test '#import_status returns imported for imported doc' do
    doc_import = DocumentImport.new

    doc_import.mapped_at = Time.now
    doc_import.imported_at = Time.now

    assert_equal :imported, doc_import.import_status
  end

  test '#import_status returns mapped for mapped doc' do
    doc_import = DocumentImport.new

    doc_import.prepared_at = Time.now
    doc_import.mapped_at = Time.now

    assert_equal :mapped, doc_import.import_status
  end

  test '#import_status returns prepared for prepared doc' do
    doc_import = DocumentImport.new
    
    doc_import.prepared_at = Time.now

    assert_equal :prepared, doc_import.import_status
  end

  test '#import_status returns waiting for non-prepared doc' do
    doc_import = DocumentImport.new
    assert_equal :waiting, doc_import.import_status
  end
end
