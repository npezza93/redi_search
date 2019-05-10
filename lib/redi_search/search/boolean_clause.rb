# frozen_string_literal: true

module RediSearch
  class Search
    class BooleanClause
      def initialize(search, term, prior_clause = nil, **term_options)
        @search = search
        @prior_clause = prior_clause
        @not = false

        initialize_terms(term, **term_options)
      end

      def to_s
        raise ArgumentError, "missing query terms" if query_terms.blank?

        [
          prior_clause.presence,
          parenthesize(queryify_terms).dup.prepend(not_operator)
        ].compact.join(operand)
      end

      def inspect
        to_s.inspect
      end

      def not(term, **term_options)
        @not = true

        initialize_terms(term, **term_options)

        search
      end

      private

      attr_reader :prior_clause, :query_terms, :search

      def parenthesize(terms)
        if terms.count > 1
          "(#{terms.join(operand)})"
        else
          terms.join(operand)
        end
      end

      def operand
        raise NotImplementedError
      end

      def not_operator
        return "" unless @not

        "-"
      end

      def initialize_terms(term, **term_options)
        return if term.blank?

        @query_terms ||= []
        @query_terms <<
          if term.is_a? RediSearch::Search
            term
          else
            Term.new(term, term_options)
          end
      end

      def queryify_terms
        query_terms.map do |term|
          if term.is_a? RediSearch::Search
            "(#{term.term_clause})"
          else
            term.to_s
          end
        end
      end
    end
  end
end
