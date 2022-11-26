# frozen_string_literal: true

module RediSearch
  class Aggregate
    module Clauses
      class Verbatim < ApplicationClause
        clause_order 1

        def clause
          validate!

          ["VERBATIM"]
        end
      end
    end
  end
end
