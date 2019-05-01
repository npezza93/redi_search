# frozen_string_literal: true

module RediSearch
  class Search
    class HighlightClause
      def initialize(**options)
        @options = options.to_h

        parse_options
      end

      def clause
        [
          "HIGHLIGHT",
          (fields_clause(**options[:fields]) if options.key?(:fields)),
          (tags_clause(**options[:tags]) if options.key? :tags),
        ].compact.flatten(1)
      end

      private

      attr_reader :options, :tags_args, :fields_args

      def parse_options
        return if options.except(:fields, :tags).empty?

        arg_error "Unsupported argument: #{options}"
      end

      def tags_clause(open:, close:)
        ["TAGS", open, close]
      end

      def fields_clause(num:, field:)
        ["FIELDS", num, field]
      end

      def arg_error(msg)
        raise ArgumentError, "Highlight: #{msg}"
      end
    end
  end
end
