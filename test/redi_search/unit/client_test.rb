# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ClientTest < Minitest::Test
    def test_call!
      redis_mock =
        Minitest::Mock.new.expect(:call, "OK", ["FT.SEARCH", "users", "foo"])

      assert_equal(Client::Response.new("OK"),
                   Client.new(redis_mock).call!("SEARCH", "users", "foo"))
      assert_mock redis_mock
    end

    def test_pipelined
      redis_mock = Minitest::Mock.new.expect(:pipelined, ["OK"])

      assert_equal([Client::Response.new("OK")],
                   Client.new(redis_mock).pipelined do
                     "OK"
                   end)
      assert_mock redis_mock
    end
  end
end
