# frozen_string_literal: true

require "test_helper"

class ValidatableDouble
  include RediSearch::Validatable

  validates_presence_of :thing

  attr_reader :thing
end

module RediSearch
  class ValidatableTest < Minitest::Test
    def test_responds_to_validates_inclusion_of
      assert_respond_to ValidatableDouble, :validates_inclusion_of
    end

    def test_responds_to_validates_presence_of
      assert_respond_to ValidatableDouble, :validates_presence_of
    end

    def test_responds_to_validates_numericality_of
      assert_respond_to ValidatableDouble, :validates_numericality_of
    end

    def test_responds_to_validate!
      assert_respond_to ValidatableDouble.new, :validate!
    end

    def test_validates_instance
      assert_raises ValidationError do
        ValidatableDouble.new.validate!
      end
    end

    def test_validations_are_stored_on_the_class
      assert_equal 1, ValidatableDouble.validations.count
      assert_includes(
        ValidatableDouble.validations.map(&:class),
        Validations::Presence
      )
    end
  end
end
