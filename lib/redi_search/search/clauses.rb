# frozen_string_literal: true

require "redi_search/search/term"
require "redi_search/search/clauses/slop"
require "redi_search/search/clauses/in_order"
require "redi_search/search/clauses/language"
require "redi_search/search/clauses/sort_by"
require "redi_search/search/and_clause"
require "redi_search/search/or_clause"
require "redi_search/search/where_clause"

module RediSearch
  class Search
    module Clauses
      def highlight(fields: [], tags: {})
        clauses.push(*HighlightClause.new(
          fields: fields, tags: tags
        ).clause)

        self
      end

      def slop(slop)
        clauses.push(*Slop.new(slop: slop).clause)

        self
      end

      def in_order
        clauses.push(*InOrder.new.clause)

        self
      end

      def no_content
        @no_content = true
        clauses.push("NOCONTENT")

        self
      end

      def language(language)
        clauses.push(*Language.new(language: language).clause)

        self
      end

      def sort_by(field, order: :asc)
        clauses.push(*SortBy.new(field: field, order: order).clause)

        self
      end

      def limit(num, offset = 0)
        clauses.push("LIMIT", offset, num)

        self
      end

      def where(**condition)
        @term_clause = WhereClause.new(self, condition, @term_clause)

        if condition.blank?
          @term_clause
        else
          self
        end
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
