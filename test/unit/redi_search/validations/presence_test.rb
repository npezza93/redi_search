# frozen_string_literal: true

require "test_helper"

module RediSearch
  module Validations
    class PresenceTest < Minitest::Test
      def test_validate_success
        validator = Validations::Presence.new(field: :field)
        mock = Minitest::Mock.new.expect(:field, true)

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_validate_success_empty
        validator = Validations::Presence.new(field: :field)
        mock = Minitest::Mock.new.expect(:field, [true])

        assert validator.validate!(mock)
        assert_mock mock
      end

      def test_invalid_failure
        validator = Validations::Presence.new(field: :field)
        mock = Minitest::Mock.new.expect(:field, false)

        assert_raises ValidationError do
          validator.validate!(mock)
        end

        assert_mock mock
      end

      def test_invalid_failure_empty
        validator = Validations::Presence.new(field: :field)
        mock = Minitest::Mock.new.expect(:field, [])

        assert_raises ValidationError do
          validator.validate!(mock)
        end

        assert_mock mock
      end
    end
  end
end
