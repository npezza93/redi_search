# frozen_string_literal: true

module RediSearch
  class Schema
    class Field
      private

      FALSES = [
        nil, "", false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"
      ].freeze

      def boolean_options_string
        boolean_options.map do |option|
          unless FALSES.include?(send(option))
            option.to_s.upcase.split("_").join
          end
        end.compact
      end
    end
  end
end
