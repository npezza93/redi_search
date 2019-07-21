# frozen_string_literal: true

module RediSearch
  module Validations
    class Presence
      def initialize(field:)
        @field = field
      end

      def validate!(object)
        return true if value_present?(object.send(field))

        raise RediSearch::ValidationError, "#{field} can't be blank"
      end

      private

      attr_reader :field

      def value_present?(value)
        if value.respond_to?(:empty?)
          !value.empty?
        else
          value
        end
      end
    end
  end
end
