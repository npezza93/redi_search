# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Boolean
        def initialize(search, term, prior_clause = nil, **term_options)
          @search = search
          @prior_clause = prior_clause
          @not = false

          initialize_term(term, **term_options)
        end

        def to_s
          raise ArgumentError, "missing query terms" if term.blank?

          [
            prior_clause.presence,
            queryify_term.dup.prepend(not_operator)
          ].compact.join(operand)
        end

        delegate :inspect, to: :to_s

        def not(term, **term_options)
          @not = true

          initialize_term(term, **term_options)

          search
        end

        private

        attr_reader :prior_clause, :term, :search

        def operand
          raise NotImplementedError
        end

        def not_operator
          return "" unless @not

          "-"
        end

        def initialize_term(term, **term_options)
          return if term.blank?

          @term =
            if term.is_a? RediSearch::Search
              term
            else
              Term.new(term, term_options)
            end
        end

        def queryify_term
          if group_term_clause?
            "(#{term.term_clause})"
          elsif term.is_a?(RediSearch::Search)
            term.term_clause
          else
            term
          end.to_s
        end

        def group_term_clause?
          term.is_a?(RediSearch::Search) &&
            !term.term_clause.is_a?(RediSearch::Search::Clauses::Where)
        end
      end
    end
  end
end
