# frozen_string_literal: true

module RediSearch
  class Search
    class Term
      include ActiveModel::Validations

      validates :fuzziness, numericality: {
        only_integer: true, less_than: 4, greater_than: 0, allow_blank: true
      }
      validates :option, inclusion: { in: %i(fuzziness optional prefix) },
                         allow_nil: true

      def initialize(term, **options)
        @term = term
        @options = options

        validate!
      end

      def to_s
        if @term.is_a? Range
          stringify_range
        else
          stringify_query
        end
      end

      private

      attr_accessor :term, :options

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
        @term.to_s.
          tr("`", "\`").
          yield_self { |str| "#{fuzzy_operator}#{str}#{fuzzy_operator}" }.
          yield_self { |str| "#{optional_operator}#{str}" }.
          yield_self { |str| "#{str}#{prefix_operator}" }.
          yield_self { |str| "`#{str}`" }
      end

      def stringify_range
        first, last = @term.first, @term.last
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
