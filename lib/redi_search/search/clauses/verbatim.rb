# frozen_string_literal: true

require "redi_search/search/clauses/application_clause"

module RediSearch
  class Search
    module Clauses
      class Verbatim < ApplicationClause
        def clause
          validate!

          ["VERBATIM"]
        end
      end
    end
  end
end
