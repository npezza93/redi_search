# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class WithScores < ApplicationClause
        def clause
          validate!

          ["WITHSCORES"]
        end
      end
    end
  end
end
