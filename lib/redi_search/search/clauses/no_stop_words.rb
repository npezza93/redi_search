# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class NoStopWords < ApplicationClause
        clause_order 3

        def clause
          validate!

          ["NOSTOPWORDS"]
        end
      end
    end
  end
end
