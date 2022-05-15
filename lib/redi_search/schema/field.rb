# frozen_string_literal: true

module RediSearch
  class Schema
    class Field
      def name
        @name&.to_sym
      end

      def coerce(value)
        value
      end

      def cast(value)
        value
      end

      def serialize(record)
        if value_block
          record.instance_exec(&value_block)
        else
          record.public_send(name)
        end
      end

      private

      attr_reader :value_block

      FALSES = [
        nil, "", false, 0, "0", "f", "F", "false", "FALSE", "off", "OFF"
      ].freeze

      def boolean_options_string
        boolean_options.filter_map do |option|
          option.to_s.upcase.split("_").join unless
            FALSES.include?(send(option))
        end
      end
    end
  end
end
