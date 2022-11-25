# frozen_string_literal: true

module RediSearch
  class Search
    module Queries
      class Boolean
        extend Forwardable

        def initialize(search, term, prior_clause = nil, **term_options)
          @search = search
          @prior_clause = prior_clause
          @not = false

          initialize_term(term, **term_options) if term
        end

        def to_s
          raise ArgumentError, "missing query terms" unless term

          [prior_clause, queryify_term].compact.join(operand)
        end

        def_delegator :to_s, :inspect

        def not(term, **term_options)
          @not = true

          initialize_term(term, **term_options) if term

          search
        end

        private

        attr_reader :prior_clause, :term, :search

        def operand
          raise NotImplementedError, "#{__method__} needs to be defined"
        end

        def not_operator
          return "" unless @not

          "-"
        end

        def initialize_term(term, **term_options)
          @term = if term.is_a? RediSearch::Search
                    term
                  else
                    Term.new(term, nil, **term_options)
                  end
        end

        def queryify_term
          if term_is_search?
            queryify_search
          else
            term
          end.to_s.dup.prepend(not_operator)
        end

        def term_is_search?
          term.is_a? RediSearch::Search
        end

        def queryify_search
          if term.query.is_a?(RediSearch::Search::Queries::Where)
            term.query
          else
            "(#{term.query})"
          end
        end
      end
    end
  end
end
