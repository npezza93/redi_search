# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

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
