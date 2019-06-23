# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class Limit < ApplicationClause
        clause_term :total, presence: true,
                            numericality: { greater_than_or_equal_to: 0 }
        clause_term :offset, presence: true,
                             numericality: { greater_than_or_equal_to: 0 }

        def initialize(total:, offset: 0)
          @total = total
          @offset = offset
        end

        def clause
          validate!

          ["LIMIT", offset, total]
        end
      end
    end
  end
end
