# frozen_string_literal: true

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
