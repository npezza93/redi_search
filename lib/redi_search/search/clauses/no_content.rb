# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class NoContent < ApplicationClause
        clause_order 1

        def clause
          validate!

          ["NOCONTENT"]
        end
      end
    end
  end
end
