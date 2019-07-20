# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AddTest < Minitest::Test
    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
      @document = Document.for_object(@index, users(index: 0))
    end

    def test_adds_document_to_index
      client = client_mock
      mock_configuration(client) do
        assert Add.new(@index, @document).call
      end
      assert_mock client
    end

    def test_if_call_fails_false_is_returned
      exceptional_client_mock do
        refute Add.new(@index, @document).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      exceptional_client_mock do
        assert_raises Redis::CommandError do
          Add.new(@index, @document).call!
        end
      end
    end

    def test_validation_fails_if_score_is_not_correct
      ["thing", -1, 1.5].each do |score|
        assert_raises ValidationError do
          Add.new(@index, @document, score: score).call
        end
      end
    end

    def test_replace_partial_clause
      client = client_mock(%w(REPLACE PARTIAL))
      mock_configuration(client) do
        assert Add.new(@index, @document, replace: { partial: true }).call
      end
      assert_mock client
    end

    def test_replace_clause
      client = client_mock(["REPLACE"])
      mock_configuration(client) do
        assert Add.new(@index, @document, replace: true).call
      end
      assert_mock client
    end

    def test_no_save_clause
      client = client_mock("NOSAVE")
      mock_configuration(client) do
        assert Add.new(@index, @document, no_save: true).call
      end
      assert_mock client
    end

    private

    def exceptional_client_mock
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        mock_configuration(client) do
          yield
        end
      end
    end

    def client_mock(options = nil)
      Minitest::Mock.new.expect(
        :call!, Client::Response.new("OK"), [
          "ADD", @index.name, @document.document_id, 1.0, options,
          "FIELDS", ["first", @document.first, "last", @document.last]
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
