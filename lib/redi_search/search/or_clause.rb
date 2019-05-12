# frozen_string_literal: true

require "redi_search/search/boolean_clause"

module RediSearch
  class Search
    class OrClause < BooleanClause
      def where(**condition)
        @term = search.dup.where(condition)

        search
      end

      private

      def operand
        "|"
      end
    end
  end
end
