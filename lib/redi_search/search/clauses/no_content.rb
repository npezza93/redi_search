# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class NoContent < ApplicationClause
        def clause
          validate!

          ["NOCONTENT"]
        end
      end
    end
  end
end
