# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class WithScores < ApplicationClause
        clause_order 4

        def clause
          validate!

          ["WITHSCORES"]
        end
      end
    end
  end
end
