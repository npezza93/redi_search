# frozen_string_literal: true

require "test_helper"

module RediSearch
  module Validations
    class NumericalityTest < Minitest::Test
      def test_validate_success
        validator = Validations::Numericality.new(field: :field, within: 0..1)
        mock = Minitest::Mock.new
        mock.expect(:field, 0.5)
        mock.expect(:field, 0.5)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_validate_success_for_integers
        validator = Validations::Numericality.
                    new(field: :field, within: 0..2, only_integer: true)
        mock = Minitest::Mock.new.expect(:field, 1)
        mock.expect(:field, 1)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_validate_success_that_allows_nil
        validator = Validations::Numericality.new(
          field: :field, within: 0..2, allow_nil: true
        )
        mock = Minitest::Mock.new.expect(:field, nil)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_invalid_failure
        validator = Validations::Numericality.new(field: :field, within: 0..1)
        mock = Minitest::Mock.new.expect(:field, 2)
        mock.expect(:field, 2)

        assert_raises(ValidationError) { validator.validate!(mock) }
        assert_mock mock
      end

      def test_invalid_failure_for_only_integers
        validator = Validations::Numericality.
                    new(field: :field, within: 0..1, only_integer: true)
        mock = Minitest::Mock.new.expect(:field, 0.5)

        assert_raises(ValidationError) { validator.validate!(mock) }
        assert_mock mock
      end

      def test_invalid_when_nil
        validator = Validations::Numericality.new(field: :field, within: 0..1)
        mock = Minitest::Mock.new.expect(:field, nil)

        assert_raises(ValidationError) { validator.validate!(mock) }
        assert_mock mock
      end
    end
  end
end
