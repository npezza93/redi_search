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
        apply_fuzziness.tr("`", "\`").then do |str|
          "`#{str}`"
        end
      end

      private

      attr_accessor :term, :options

      def apply_fuzziness
        amount = options[:fuzziness].to_i
        if amount.negative? || amount > 3
          raise ArgumentError, "fuzziness can only be between 0 and 3"
        end

        ("%" * amount).then do |fuzziness|
          "#{fuzziness}#{term}#{fuzziness}"
      def validate_options
        unsupported_options =
          (options.keys.map(&:to_s) - %w(fuzziness optional)).join(", ")

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
