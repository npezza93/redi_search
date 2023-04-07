# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      def no_content
        add_to_clauses(NoContent.new)
      end

      def verbatim
        add_to_clauses(Verbatim.new)
      end

      def no_stop_words
        add_to_clauses(NoStopWords.new)
      end

      def with_scores
        add_to_clauses(WithScores.new)
      end

      def with_payloads
        add_to_clauses(WithPayloads.new)
      end

      def with_sort_keys
        add_to_clauses(WithSortKeys.new)
      end

      def return(*fields)
        add_to_clauses(Return.new(fields: fields))
      end

      def params(*fields)
        add_to_clauses(Params.new(fields: fields))
      end

      def highlight(fields: [], opening_tag: "<b>", closing_tag: "</b>")
        add_to_clauses(Highlight.new(
          fields: fields, opening_tag: opening_tag, closing_tag: closing_tag
        ))
      end

      def slop(slop)
        add_to_clauses(Slop.new(slop: slop))
      end

      def dialect(dialect)
        add_to_clauses(Dialect.new(dialect: dialect))
      end

      def timeout(timeout)
        add_to_clauses(Timeout.new(timeout: timeout))
      end

      def in_order
        add_to_clauses(InOrder.new)
      end

      def language(language)
        add_to_clauses(Language.new(language: language))
      end

      def sort_by(field, order: :asc)
        add_to_clauses(SortBy.new(field: field, order: order))
      end

      def limit(total, offset = 0)
        add_to_clauses(Limit.new(total: total, offset: offset))
      end

      def count
        return to_a.size if loaded?

        RediSearch.client.call!(
          "SEARCH", index.name, query.to_s, *Limit.new(total: 0).clause
        ).first
      end

      private

      def add_to_clauses(clause)
        clause.validate! && clauses.push(clause) if
          used_clauses.add?(clause.class)

        self
      end
    end
  end
end
