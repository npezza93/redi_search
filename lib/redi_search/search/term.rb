# frozen_string_literal: true

module RediSearch
  class Search
    class Term
      include Validatable

      validates_numericality_of :fuzziness, within: 1..3, only_integer: true,
                                            allow_nil: true
      validates_inclusion_of :option, within: %i(fuzziness optional prefix),
                                      allow_nil: true

      def initialize(term, field = nil, **options)
        @term    = term
        @field   = field
        @options = options

        validate!
      end

      def to_s
        if term.is_a?(Range) then stringify_range
        elsif field.is_a?(Schema::TagField) then stringify_tag
        elsif term.is_a?(Array) then stringify_array
        else
          stringify_query
        end
      end

      private

      attr_accessor :term, :field, :options

      def fuzziness
        @fuzziness ||= options[:fuzziness]
      end

      def optional_operator
        return unless options[:optional]

        "~"
      end

      def prefix_operator
        return unless options[:prefix]

        "*"
      end

      def fuzzy_operator
        "%" * fuzziness.to_i
      end

      def stringify_query
        term.to_s.
          tr("`", "`").
          then { |str| "#{fuzzy_operator}#{str}#{fuzzy_operator}" }.
          then { |str| "#{optional_operator}#{str}" }.
          then { |str| "#{str}#{prefix_operator}" }.
          then { |str| "`#{str}`" }
      end

      def stringify_tag
        "{ #{Array(term).join(' | ')} }"
      end

      def stringify_array
        Array(term).map { |str| "`#{str}`" }.join(" | ")
      end

      def stringify_range
        first, last = term.first, term.last
        first = "-inf" if first == -Float::INFINITY
        last = "+inf" if last == Float::INFINITY

        "[#{first} #{last}]"
      end

      def option
        options.keys.first&.to_sym
      end
    end
  end
end
