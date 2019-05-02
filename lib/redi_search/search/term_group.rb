# frozen_string_literal: true

module RediSearch
  class Search
    class TermGroup
      def initialize(initial_term, operation, new_term)
        @initial_term = initial_term
        @operation = operation
        @new_term = new_term
      end
    end
  end
end
