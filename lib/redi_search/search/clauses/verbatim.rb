# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Verbatim < ApplicationClause
        clause_order 2

        def clause
          validate!

          ["VERBATIM"]
        end
      end
    end
  end
end
