# frozen_string_literal: true

module RediSearch
  module Validations
    class Numericality
      def initialize(field:, within:, only_integer: false, allow_nil: false)
        @field = field
        @within = within
        @only_integer = only_integer
        @allow_nil = allow_nil
      end

      def validate!(object)
        value = object.send(field)

        return true if value.nil? && allow_nil?

        validate_numberness!(value)
        validate_inclusion!(object)
      end

      private

      attr_reader :field, :within, :only_integer, :allow_nil
      alias only_integer? only_integer
      alias allow_nil? allow_nil

      def validate_numberness!(value)
        raise(ValidationError, "#{field} must be a number") unless
          value.is_a?(Numeric)

        raise(ValidationError, "#{field} must be an Integer") if
          only_integer? && !value.is_a?(Integer)

        true
      end

      def validate_inclusion!(object)
        Inclusion.new(field: field, within: within).validate!(object)
      end
    end
  end
end
