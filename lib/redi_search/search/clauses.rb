# frozen_string_literal: true

require "redi_search/search/term"
require "redi_search/search/and_clause"
require "redi_search/search/or_clause"
require "redi_search/search/where_clause"

module RediSearch
  class Search
    module Clauses
      def highlight(**options)
        clauses.push(*HighlightClause.new(**options).clause)

        self
      end

      def slop(slop)
        clauses.push("SLOP", slop)

        self
      end

      def in_order
        clauses.push("INORDER")

        self
      end

      def no_content
        @no_content = true
        clauses.push("NOCONTENT")

        self
      end

      def language(language)
        clauses.push("LANGUAGE", language)

        self
      end

      def sort_by(field, order: :asc)
        raise ArgumentError unless %i(asc desc).include?(order.to_sym)

        clauses.push("SORTBY", field, order)

        self
      end

      def limit(num, offset = 0)
        clauses.push("LIMIT", offset, num)

        self
      end

      def where(condition, **term_options)
        @term_clause = WhereClause.new(condition, @term_clause, **term_options)

        self
      end

      def and(new_term = nil, **term_options)
        @term_clause =
          AndClause.new(self, new_term, @term_clause, **term_options)

        if new_term.blank?
          @term_clause
        else
          self
        end
      end

      def or(new_term = nil, **term_options)
        @term_clause =
          OrClause.new(self, new_term, @term_clause, **term_options)

        if new_term.blank?
          @term_clause
        else
          self
        end
      end
    end
  end
end
