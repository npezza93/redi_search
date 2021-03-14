# frozen_string_literal: true

module RediSearch
  class Schema
    class Field
      attr_reader :name

      private

      FALSES = [
        nil, "", false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"
      ].freeze

      def boolean_options_string
        boolean_options.map do |option|
          option.to_s.upcase.split("_").join unless
            FALSES.include?(send(option))
        end.compact
      end
    end
  end
end
