# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SearchTest < Minitest::Test
    def setup
      @search = Search.new(Index.new(:users, name: :text), "foo")
    end

    def test_explain
      client = Minitest::Mock.new.expect(:call!, response(%w(ex plain)),
                                         ["EXPLAINCLI", "users", "`foo`"])

      RediSearch.stub(:client, client) { @search.explain }

      assert_mock client
    end

    private

    def response(raw_response)
      Client::Response.new(raw_response)
    end
  end
end
