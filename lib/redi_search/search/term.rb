# frozen_string_literal: true

module RediSearch
  class Search
    class Term
      def initialize(term, **options)
        @term = term
        @options = options
      end

      def to_s
        "`#{apply_fuzziness}`"
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
        end
      end
    end
  end
end
