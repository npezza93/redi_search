# frozen_string_literal: true

require "redi_search/search/term"
require "redi_search/search/and_clause"
require "redi_search/search/or_clause"

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

      def and(*new_terms, **terms_with_options)
        @term_clause =
          AndClause.new(self, @term_clause, *new_terms, **terms_with_options)

        if new_terms.blank? && terms_with_options.blank?
          @term_clause
        else
          self
        end
      end

      def or(*new_terms, **terms_with_options)
        @term_clause =
          OrClause.new(self, @term_clause, *new_terms, **terms_with_options)

        if new_terms.blank? && terms_with_options.blank?
          @term_clause
        else
          self
        end
      end
    end
  end
end
