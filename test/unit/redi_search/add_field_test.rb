# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AddFieldTest < Minitest::Test
    def setup
      @index = Index.new(:cars, make: :text)
    end

    def test_adds_document_to_index
      mock_client("model", "TEXT", "WEIGHT", 1.0) do
        assert AddField.new(@index, :model, :text).call
        assert_includes @index.fields, "model"
      end
    end

    def test_if_call_fails_false_is_returned
      mock_exceptional_client do
        refute AddField.new(@index, :model, :text).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      mock_exceptional_client do
        assert_raises Redis::CommandError do
          AddField.new(@index, :model, :text).call!
        end
      end
    end

    private

    def mock_exceptional_client
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        RediSearch.stub(:client, client) { yield }
      end
    end

    def mock_client(*field_schema)
      client = Minitest::Mock.new.expect(:call!, Client::Response.new("OK"), [
        "ALTER", @index.name, "SCHEMA", "ADD", *field_schema
      ])

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end
  end
end
