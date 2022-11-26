# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class Limit < ApplicationClause
        clause_term :total, presence: true, numericality: {
          within: 0..Float::INFINITY, only_integer: true
        }
        clause_term :offset, presence: true, numericality: {
          within: 0..Float::INFINITY, only_integer: true
        }
        clause_order 7

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
