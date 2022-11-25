# frozen_string_literal: true

module RediSearch
  class Search
    module Queries
      def where(**condition)
        @query = Search::Queries::Where.new(self, condition, @query)

        self
      end

      def not(**condition)
        raise NoMethodError unless @query.is_a?(Search::Queries::Where)

        @query.not(condition)
      end

      def and(new_term = nil, **term_options)
        @query = Queries::And.new(self, new_term, @query, **term_options)

        if new_term.nil?
          @query
        else
          self
        end
      end

      def or(new_term = nil, **term_options)
        @query = Queries::Or.new(self, new_term, @query, **term_options)

        if new_term.nil?
          @query
        else
          self
        end
      end
    end
  end
end
