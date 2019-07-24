# frozen_string_literal: true

require "test_helper"

module RediSearch
  class LazilyLoadTest < Minitest::Test
    def setup
      @double = Object.new
      @double.extend LazilyLoad
    end

    def test_not_implemented_error_is_raised_if_command_isnt_defined
      assert_raises NotImplementedError do
        @double.to_a
      end
    end

    def test_not_implemented_error_is_raised_if_parse_response_isnt_defined
      @double.stub(:call!, "OK") do
        @double.stub(:command, %w(INFO users_test)) do
          assert_raises(NotImplementedError) { @double.to_a }
        end
      end
    end
  end
end
