# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AlterTest < Minitest::Test
    def setup
      @index = Index.new(:cars, make: :text)
    end

    def test_adds_document_to_index
      client = client_mock("model", "TEXT", "WEIGHT", 1.0)
      mock_configuration(client) do
        assert Alter.new(@index, :model, :text).call
        assert_includes @index.fields, "model"
      end
      assert_mock client
    end

    def test_if_call_fails_false_is_returned
      exceptional_client_mock do
        refute Alter.new(@index, :model, :text).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      exceptional_client_mock do
        assert_raises Redis::CommandError do
          Alter.new(@index, :model, :text).call!
        end
      end
    end

    private

    def exceptional_client_mock
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        mock_configuration(client) do
          yield
        end
      end
    end

    def client_mock(*field_schema)
      Minitest::Mock.new.expect(
        :call!, Client::Response.new("OK"), [
          "ALTER", @index.name, "SCHEMA", "ADD", *field_schema
        ].compact
      )
    end

    def mock_configuration(client)
      configuration = Minitest::Mock.new.expect :client, client
      RediSearch.configuration = configuration

      yield
      assert_mock configuration
      RediSearch.configuration = nil
    end
  end
end
