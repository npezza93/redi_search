# frozen_string_literal: true

require "test_helper"
require "redi_search/client"

module RediSearch
  class ClientTest < ActiveSupport::TestCase
    test "Response#ok? with string" do
      assert Client::Response.new("OK").ok?
    end

    test "Response#ok? with array" do
      assert Client::Response.new(%w(OK OK)).ok?
    end

    test "Response#ok? with other object" do
      assert Client::Response.new({ thing: 1 }).ok?
      assert_equal({ thing: 1 }, Client::Response.new({ thing: 1 }).ok?)
    end
  end
end
