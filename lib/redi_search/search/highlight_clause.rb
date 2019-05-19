# frozen_string_literal: true

module RediSearch
  class Search
    class HighlightClause
      def initialize(fields: [], tags: {})
        @fields = fields
        @tags = tags.to_h
      end

      def clause
        [
          "HIGHLIGHT",
          fields_clause,
          tags_clause,
        ].compact.flatten(1)
      end

      private

      attr_reader :options, :tags_args, :fields_args

      def tags_clause
        return if @tags.empty?

        if @tags[:open].present? && @tags[:close].present?
          ["TAGS", @tags[:open], @tags[:close]]
        else
          arg_error("Missing opening or closing tag")
        end
      end

      def fields_clause
        return if @fields.empty?

        ["FIELDS", @fields.size, @fields]
      end

      def arg_error(msg)
        raise ArgumentError, "Highlight: #{msg}"
      end
    end
  end
end
