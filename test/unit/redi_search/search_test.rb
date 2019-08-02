# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SearchTest < Minitest::Test
    def test_explain
      client = Minitest::Mock.new.expect(:call!, response(%w(ex plain)),
                                         ["EXPLAINCLI", "users", "`foo`"])

      RediSearch.stub(:client, client) { search.explain }

      assert_mock client
    end

    def test_results_without_model
      result = Search::Result.new(
        search, 1, ["users1", %w(name foo)]
      )

      search.stub(:to_a, result) do
        assert_equal result, search.results
      end
    end

    def test_results_with_model
      search_with_model do |search|
        result = Search::Result.new(search, 1, ["users1", %w(name foo)])

        search.stub(:to_a, result) do
          assert_equal active_record_relation_double, search.results
        end
      end
    end

    def test_inspect
      result = Search::Result.new(search, 1, ["users1", %w(name foo)])

      search.stub(:loaded?, true) do
        search.stub(:documents, result) do
          assert_equal result, search.inspect
        end
      end
    end

    def test_inspect_with_exception
      Client.new.
        stub(:call!, ->(*) { raise(Redis::CommandError, "error") }) do |client|
        RediSearch.stub(:client, client) do
          assert_equal "error", search.inspect
        end
      end
    end

    private

    def response(raw_response)
      Client::Response.new(raw_response)
    end

    def active_record_relation_double
      @active_record_relation_double ||= [Object.new]
    end

    def search_with_model
      model = Minitest::Mock.new.expect(:where, active_record_relation_double,
                                        [{ id: ["1"] }])
      Search.new(
        Index.new(:users, { name: :text }, model), "foo"
      ).yield_self { |search| yield search }

      assert_mock model
    end

    def search
      @search ||= Search.new(
        Index.new(:users, name: :text), "foo"
      )
    end
  end
end
