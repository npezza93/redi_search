# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class Filter < ApplicationClause
        clause_term :expression, presence: true
        clause_order 6

        def initialize(expression:)
          @expression = expression
        end

        def clause
          validate!

          ["FILTER", expression]
        end
      end
    end
  end
end
