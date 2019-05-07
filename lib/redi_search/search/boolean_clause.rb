# frozen_string_literal: true

module RediSearch
  class Search
    class BooleanClause
      def initialize(search, prior_clause = nil, *terms, **terms_with_options)
        @search = search
        @prior_clause = prior_clause
        @not = false

        initialize_terms(*terms, **terms_with_options)
      end

      def to_s
        raise ArgumentError, "missing query terms" if query_terms.blank?

        [
          prior_clause.presence,
          parenthesize(query_terms.map(&:to_s)).dup.prepend(not_operator)
        ].compact.join(operand)
      end

      def inspect
        to_s.inspect
      end

      def not(*terms, **terms_with_options)
        @not = true

        initialize_terms(*terms, **terms_with_options)

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

      def initialize_terms(*terms, **terms_with_options)
        @query_terms = terms.map do |term|
          Term.new(term)
        end
        terms_with_options.each do |term, options|
          @query_terms << Term.new(term, options)
        end
      end
    end
  end
end
