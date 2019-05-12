# frozen_string_literal: true

module RediSearch
  class Search
    class WhereClause
      def initialize(condition, prior_clause = nil, **term_options)
        @prior_clause = prior_clause

        initialize_term(condition.flatten, **term_options)
      end

      def to_s
        [prior_clause.presence, "@#{field}:#{queryify_term}"].compact.join(" ")
      end

      def inspect
        to_s.inspect
      end

      private

      attr_reader :prior_clause, :term, :field

      def queryify_term
        if term.is_a? RediSearch::Search
          "(#{term.term_clause})"
        else
          term.to_s
        end
      end

      def initialize_term(condition, **term_options)
        raise ArgumentError if condition.count != 2

        @field = condition[0]
        @term =
          if condition[1].is_a? RediSearch::Search
            condition[1]
          else
            Term.new(condition[1], term_options)
          end
      end
    end
  end
end
