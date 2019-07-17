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
require "redi_search/search/clauses/return"
require "redi_search/search/clauses/with_scores"
require "redi_search/search/clauses/highlight"
require "redi_search/search/clauses/and"
require "redi_search/search/clauses/or"
require "redi_search/search/clauses/where"

module RediSearch
  class Search
    module Clauses
      def highlight(fields: [], opening_tag: "<b>", closing_tag: "</b>")
        add_to_clause(Highlight.new(
          fields: fields, opening_tag: opening_tag, closing_tag: closing_tag
        ))
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

      def with_scores
        add_to_clause(WithScores.new)
      end

      def no_content
        add_to_clause(NoContent.new)
      end

      def return(*fields)
        add_to_clause(Return.new(fields: fields))
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

      def count
        return to_a.size if loaded?

        call!(
          "SEARCH", index.name, term_clause, *Limit.new(total: 0).clause
        ).first
      end

      def where(**condition)
        @term_clause = Where.new(self, condition, @term_clause)

        if condition.nil?
          @term_clause
        else
          self
        end
      end

      def and(new_term = nil, **term_options)
        @term_clause = And.new(self, new_term, @term_clause, **term_options)

        if new_term.nil?
          @term_clause
        else
          self
        end
      end

      def or(new_term = nil, **term_options)
        @term_clause = Or.new(self, new_term, @term_clause, **term_options)

        if new_term.nil?
          @term_clause
        else
          self
        end
      end

      private

      def add_to_clause(clause)
        used_clauses.add(clause.class.name.demodulize.underscore)
        clauses.push(*clause.clause)

        self
      end
    end
  end
end
