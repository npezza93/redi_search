# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Highlight
        def initialize(fields: [], opening_tag: "<b>", closing_tag: "</b>")
          @fields = fields
          @opening_tag = opening_tag
          @closing_tag = closing_tag
        end

        def clause
          [
            "HIGHLIGHT",
            fields_clause,
            tags_clause,
          ].compact.flatten(1)
        end

        private

        attr_reader :fields, :opening_tag, :closing_tag

        def tags_clause
          return if opening_tag.blank? && closing_tag.blank?

          if opening_tag.present? && closing_tag.present?
            ["TAGS", opening_tag, closing_tag]
          else
            arg_error("Missing opening or closing tag")
          end
        end

        def fields_clause
          return if fields.empty?

          ["FIELDS", fields.size, fields]
        end

        def arg_error(msg)
          raise ArgumentError, "Highlight: #{msg}"
        end
      end
    end
  end
end
