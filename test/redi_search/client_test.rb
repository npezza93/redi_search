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
      assert Client::Response.new(["field"]).ok?
      assert_equal ["field"], Client::Response.new(["field"]).ok?
    end
  end
end
