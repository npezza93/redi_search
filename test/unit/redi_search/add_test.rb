# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AddTest < Minitest::Test
    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @document = Document.for_object(@index, users(index: 0))
    end

    def test_adds_document_to_index
      mock_client do
        assert Add.new(@index, @document).call
      end
    end

    def test_if_call_fails_false_is_returned
      mock_exceptional_client do
        refute Add.new(@index, @document).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      mock_exceptional_client do
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
      mock_client(%w(REPLACE PARTIAL)) do
        assert Add.new(@index, @document, replace: { partial: true }).call
      end
    end

    def test_replace_clause
      mock_client(["REPLACE"]) do
        assert Add.new(@index, @document, replace: true).call
      end
    end

    def test_no_save_clause
      mock_client("NOSAVE") do
        assert Add.new(@index, @document, no_save: true).call
      end
    end

    private

    def mock_exceptional_client
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        RediSearch.stub(:client, client) { yield }
      end
    end

    def mock_client(options = nil)
      client = Minitest::Mock.new.expect(:call!, Client::Response.new("OK"), [
        "ADD", @index.name, @document.document_id, 1.0, options, "FIELDS",
        ["first", @document.first, "last", @document.last]
      ].compact)

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end
  end
end
