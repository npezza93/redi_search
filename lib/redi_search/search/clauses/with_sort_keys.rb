# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class WithSortKeys < ApplicationClause
        clause_order 6

        def clause
          validate!

          ["WITHSORTKEYS"]
        end
      end
    end
  end
end
