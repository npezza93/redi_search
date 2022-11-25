# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class InOrder < ApplicationClause
        clause_order 15

        def clause
          validate!

          ["INORDER"]
        end
      end
    end
  end
end
