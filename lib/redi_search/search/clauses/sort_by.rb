# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class SortBy < ApplicationClause
        clause_term :field, presence: true
        clause_term :order, presence: true, inclusion: { within: %i(asc desc) }
        clause_order 20

        def initialize(field:, order: :asc)
          @field = field
          @order = order.to_sym
        end

        def clause
          validate!

          ["SORTBY", field, order.upcase]
        end
      end
    end
  end
end
