# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class InOrder < ApplicationClause
        def clause
          validate!

          ["INORDER"]
        end
      end
    end
  end
end
