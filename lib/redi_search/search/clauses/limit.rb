# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class Limit < ApplicationClause
        clause_term :total, presence: true, numericality: {
          within: 0..Float::INFINITY, only_integer: true
        }
        clause_term :offset, presence: true, numericality: {
          within: 0..Float::INFINITY, only_integer: true
        }

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
