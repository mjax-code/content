module Refine::Reconcile::Helpers
  extend Grape::API::Helpers

  def jsonp(data:, callback:)
    # header 'X-Xss-Protection', '1; mode=block'
    # header 'X-Frame-Options', 'SAMEORIGIN'
    # header 'X-Content-Type-Options', 'nosniff'

    "/**/#{callback}(#{data.to_json})\n"
  end

  def model_name
    model.name
  end

  #
  # Service metadata requests inform Refine about this endpoint.
  #
  def service_metadata
    {
      name: "LT :: #{model_name} Reconciliation"
    }
  end

  #
  # Reconciliation queries do the actual reconciliation work.
  #
  def reconcile
    results = {}

    # @queries.each do |k, query|
    #   results[k] = {
    #     result: model.reconcile(query[:query], limit: query[:limit])
    #   }
    # end

    results
  end

  #
  # Parse the OpenRefine query payload.
  #
  def set_queries
    @queries = params[:queries]

    unless @queries.is_a? Hash
      @queries = JSON.parse(@queries, symbolize_names: true)
    end
  end

  #
  # Check whether this is a service metadata request.
  #
  def wants_service_metadata?
    params[:queries].blank?
  end

  #
  # Check whether this is a query request.
  #
  def wants_query?
    params[:queries].present?
  end

end
