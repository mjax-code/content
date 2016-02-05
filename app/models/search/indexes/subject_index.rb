module Search
  module Indexes

    class SubjectIndex < Index
      def mappings
        {
          subject: {
            properties: {
              id: {type: 'string', index: 'not_analyzed'},
              name: {
                type: 'multi_field',
                fields: {
                  name:    {type: 'string', index: 'not_analyzed'},
                  full:    {type: 'string', analyzer: 'full_str'},
                  partial: {type: 'string', analyzer: 'partial_str'}
                }
              }
            }
          }
        }
      end
    end

  end
end
