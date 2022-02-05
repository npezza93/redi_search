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
        elsif !field.nil? && field.tag? then stringify_tag
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
          tr("`", "\`").
          yield_self { |str| "#{fuzzy_operator}#{str}#{fuzzy_operator}" }.
          yield_self { |str| "#{optional_operator}#{str}" }.
          yield_self { |str| "#{str}#{prefix_operator}" }.
          yield_self { |str| "`#{str}`" }
      end

      def stringify_tag
        if term.is_a?(Array)
          "{ #{term.join(' | ')} }"
        else
          "{ #{term} }"
        end
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
