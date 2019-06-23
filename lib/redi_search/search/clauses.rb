# frozen_string_literal: true

require "redi_search/search/term"
require "redi_search/search/clauses/slop"
require "redi_search/search/clauses/in_order"
require "redi_search/search/clauses/language"
require "redi_search/search/clauses/sort_by"
require "redi_search/search/clauses/limit"
require "redi_search/search/clauses/no_content"
require "redi_search/search/clauses/verbatim"
require "redi_search/search/clauses/no_stop_words"
require "redi_search/search/and_clause"
require "redi_search/search/or_clause"
require "redi_search/search/where_clause"

module RediSearch
  class Search
    module Clauses
      def highlight(fields: [], tags: {})
        add_to_clause(HighlightClause.new(fields: fields, tags: tags))
      end

      def slop(slop)
        add_to_clause(Slop.new(slop: slop))
      end

      def in_order
        add_to_clause(InOrder.new)
      end

      def verbatim
        add_to_clause(Verbatim.new)
      end

      def no_stop_words
        add_to_clause(NoStopWords.new)
      end

      def no_content
        @no_content = true
        add_to_clause(NoContent.new)
      end

      def language(language)
        add_to_clause(Language.new(language: language))
      end

      def sort_by(field, order: :asc)
        add_to_clause(SortBy.new(field: field, order: order))
      end

      def limit(total, offset = 0)
        add_to_clause(Limit.new(total: total, offset: offset))
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

      private

      def add_to_clause(clause)
        clauses.push(*clause.clause)

        self
      end
    end
  end
end
