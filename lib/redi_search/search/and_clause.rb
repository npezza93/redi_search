# frozen_string_literal: true

require "redi_search/search/boolean_clause"

module RediSearch
  class Search
    class AndClause < BooleanClause
      private

      def operand
        " "
      end
    end
  end
end
