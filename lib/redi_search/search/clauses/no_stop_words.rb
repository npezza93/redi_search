# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class NoStopWords < ApplicationClause
        def clause
          validate!

          ["NOSTOPWORDS"]
        end
      end
    end
  end
end
