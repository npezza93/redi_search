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
      mock_client("OK") do
        @double.stub(:command, %w(GET key)) do
          assert_raises(NotImplementedError) { @double.to_a }
        end
      end
    end

    private

    def mock_client(response)
      client = Minitest::Mock.new.expect(
        :call!, Client::Response.new(response), %w(GET key)
      )

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end
  end
end
