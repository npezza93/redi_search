# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class Return < ApplicationClause
        clause_term :fields, presence: true

        def initialize(fields:)
          @fields = fields
        end

        def clause
          validate!

          ["RETURN", fields.size, *fields]
        end
      end
    end
  end
end
