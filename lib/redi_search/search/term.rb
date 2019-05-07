# frozen_string_literal: true

module RediSearch
  class Search
    class Term
      def initialize(term, **options)
        @term = term
        @options = options

        validate_options
      end

      def to_s
        @term.to_s.
          tr("`", "\`").
          then { |str| "#{'%' * fuzziness}#{str}#{'%' * fuzziness}" }.
          then { |str| "#{optional_operator}#{str}" }.
          then { |str| "#{str}#{prefix_operator}" }.
          then { |str| "`#{str}`" }
      end

      private

      attr_accessor :term, :options

      def fuzziness
        @fuzziness ||= options[:fuzziness].to_i
      end

      def optional_operator
        return unless options[:optional]

        "~"
      end

      def prefix_operator
        return unless options[:prefix]

        "*"
      end

      def validate_options
        unsupported_options =
          (options.keys.map(&:to_s) - %w(fuzziness optional prefix)).join(", ")

        if unsupported_options.present?
          raise(ArgumentError,
                "#{unsupported_options} are unsupported term options")
        end

        raise(ArgumentError, "fuzziness can only be between 0 and 3") if
          fuzziness.negative? || fuzziness > 3
      end
    end
  end
end
