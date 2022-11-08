# frozen_string_literal: true

require "test_helper"

module RediSearch
  module Validations
    class InclusionTest < Minitest::Test
      def test_validate_success
        validator = Validations::Inclusion.new(field: :field, within: [1])
        mock = Minitest::Mock.new.expect(:field, 1)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_validate_success_when_nil
        validator = Validations::Inclusion.
                    new(field: :field, within: [1], allow_nil: true)
        mock = Minitest::Mock.new.expect(:field, nil)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_invalid_failure
        validator = Validations::Inclusion.new(field: :field, within: [1])
        mock = Minitest::Mock.new.expect(:field, nil)

        assert_raises ValidationError do
          validator.validate!(mock)
        end

        assert_mock mock
      end

      def test_invalid_failure_empty
        validator = Validations::Inclusion.new(field: :field, within: [1])
        mock = Minitest::Mock.new.expect(:field, 2)

        assert_raises ValidationError do
          validator.validate!(mock)
        end

        assert_mock mock
      end
    end
  end
end
