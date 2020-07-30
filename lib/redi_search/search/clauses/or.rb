# frozen_string_literal: true

require "redi_search/search/clauses/boolean"

module RediSearch
  class Search
    module Clauses
      class Or < Boolean
        def where(**condition)
          @term = search.dup.where(**condition)

          search
        end

        private

        def operand
          "|"
        end
      end
    end
  end
end
