# frozen_string_literal: true

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
