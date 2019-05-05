# frozen_string_literal: true

module RediSearch
  class Search
    class BooleanClause
      def initialize(prior_clause = nil, *terms, **terms_with_options)
        @prior_clause = prior_clause
        @terms = terms.map do |term|
          Term.new(term)
        end
        terms_with_options.each do |term, options|
          @terms << Term.new(term, options)
        end
      end

      def to_s
        clause = prior_clause if prior_clause.present?

        [clause, parenthesize(@terms.map(&:to_s))].compact.join(operand)
      end

      def append(clause)
        @terms << clause
      end

      private

      attr_reader :prior_clause, :terms

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
    end
  end
end
