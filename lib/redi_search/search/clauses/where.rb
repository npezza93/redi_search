# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Where
        extend Forwardable

        def initialize(search, condition, prior_clause = nil)
          @search = search
          @prior_clause = prior_clause
          @not = false

          initialize_term(condition)
        end

        def to_s
          [
            prior_clause,
            "(#{not_operator}@#{field}:#{queryify_term})"
          ].compact.join(" ")
        end

        def_delegator :to_s, :inspect

        def not(condition)
          @not = true

          initialize_term(condition)

          search
        end

        private

        attr_reader :prior_clause, :term, :field, :search

        def queryify_term
          if term.is_a? RediSearch::Search
            "(#{term.term_clause})"
          else
            term.to_s
          end
        end

        def not_operator
          return "" unless @not

          "-"
        end

        def initialize_term(condition)
          return if condition?(condition)

          condition, *options = condition.to_a

          @field = condition[0]
          @term = make_term(condition, options)
        end

        def make_term(condition, options)
          if condition[1].is_a? RediSearch::Search
            condition[1]
          else
            Term.new(condition[1], **options.to_h)
          end
        end

        def condition?(condition)
          if condition.respond_to?(:empty?)
            condition.empty?
          else
            !condition
          end
        end
      end
    end
  end
end
