# frozen_string_literal: true

require "test_helper"
require "redi_search/client"

module RediSearch
  class ClientTest < Minitest::Test
    def test_Response_ok_with_string
      assert Client::Response.new("OK").ok?
    end

    def test_Response_ok_with_array
      assert Client::Response.new(%w(OK OK)).ok?
    end

    def test_Response_ok_with_other_object
      assert Client::Response.new({ thing: 1 }).ok?
      assert_equal({ thing: 1 }, Client::Response.new({ thing: 1 }).ok?)
    end
  end
end
