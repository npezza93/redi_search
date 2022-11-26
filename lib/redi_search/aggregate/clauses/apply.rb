# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class Apply < ApplicationClause
        clause_term :expression, presence: true
        clause_term :as, presence: true
        clause_order 5

        def initialize(expression:, as:)
          @expression = expression
          @as = as
        end

        def clause
          validate!

          ["APPLY", expression, "AS", as]
        end
      end
    end
  end
end
