class Refine::Reconcile::Languages < Grape::API
  include Refine::Reconcile::Base

  helpers do
    def model; Language end

    def reconcile_query(query)
      # model.reconcile **query
      res = Search::LanguageSearch.new.search(q: query[:query], limit: query[:limit])
      res.hits.map { |h|
        {
          id: h._id,
          name: h._source.name,
          type: ['Language'],
          score: h._score,
          match: h._score > 0.2,
        }
      }
    end
  end

  params do
    requires :callback, type: String
  end
  get '/' do
    error!("400 Bad Request", 400) unless is_service_metadata?
    service_metadata
  end

  params do
    requires :queries, type: String
  end
  post '/' do
    error!("400 Bad Request", 400) unless is_query?
    reconcile_multi parse_queries
  end
end
