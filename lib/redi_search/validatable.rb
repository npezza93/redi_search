# frozen_string_literal: true

module RediSearch
  class ValidationError < StandardError
  end

  module Validatable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :validations

      def validates_inclusion_of(field, within:, **options)
        self.validations = [
          *validations.to_a,
          Validations::Inclusion.new(field:, within:, **options)
        ]
      end

      def validates_presence_of(field)
        self.validations = [
          *validations.to_a,
          Validations::Presence.new(field:)
        ]
      end

      def validates_numericality_of(field, within:, **options)
        self.validations = [
          *validations.to_a,
          Validations::Numericality.new(
            field:, within:, **options
          )
        ]
      end
    end

    def validate!
      self.class.validations.to_a.each do |validator|
        validator.validate!(self)
      end
    end
  end
end
