# frozen_string_literal: true

module RediSearch
  class Search
    module Clauses
      class Highlight < ApplicationClause
        clause_order 12

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
          return if !opening_tag? && !closing_tag?

          if opening_tag? && closing_tag?
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

        def opening_tag?
          if opening_tag.respond_to? :empty?
            !opening_tag.empty?
          else
            opening_tag
          end
        end

        def closing_tag?
          if closing_tag.respond_to? :empty?
            !closing_tag.empty?
          else
            closing_tag
          end
        end
      end
    end
  end
end
