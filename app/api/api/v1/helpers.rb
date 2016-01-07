module API::V1::Helpers
  extend Grape::API::Helpers

  params :pagination do
    optional :page,  type: Integer, default: 1
    optional :limit, type: Integer, default: 100
  end

  def current_organization
    @current_organization ||= begin
      headers['X-Api-Key'] && ApiKey.find_by(key: headers['X-Api-Key']).organization
    end
  end

  def declared_params
    @declared_params ||= declared(params)
  end
end