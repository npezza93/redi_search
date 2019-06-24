# frozen_string_literal: true

require "redi_search/search/clauses/boolean"

module RediSearch
  class Search
    module Clauses
      class And < Boolean
        private

        def operand
          " "
        end
      end
    end
  end
end
