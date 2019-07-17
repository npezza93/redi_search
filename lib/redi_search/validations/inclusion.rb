# frozen_string_literal: true

module RediSearch
  module Validations
    class Inclusion
      def initialize(field:, within:, allow_nil: false)
        @field = field
        @within = within
        @allow_nil = allow_nil
      end

      def validate!(object)
        value = object.send(field)

        return if within.include?(value) || (allow_nil? && value.nil?)

        raise RediSearch::ValidationError, "#{value.inspect} not included in #{within}"
      end

      private

      attr_reader :field, :within, :allow_nil
      alias allow_nil? allow_nil
    end
  end
end
