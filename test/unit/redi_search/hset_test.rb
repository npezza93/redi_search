# frozen_string_literal: true

require "test_helper"

module RediSearch
  class HsetTest < Minitest::Test
    def setup
      @index = Index.new(:users) do
        text_field :first
        text_field :last
      end
      @document = Document.for_object(@index, users(index: 0))
    end

    def test_adds_document_to_index
      mock_client do
        assert Hset.new(@index, @document).call
      end
    end

    def test_if_call_fails_false_is_returned
      mock_exceptional_client do
        refute Hset.new(@index, @document).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      mock_exceptional_client do
        assert_raises Redis::CommandError do
          Hset.new(@index, @document).call!
        end
      end
    end

    private

    def mock_exceptional_client
      Client.new.stub :call!, ->(*) { raise Redis::CommandError } do |client|
        RediSearch.stub(:client, client) { yield }
      end
    end

    def mock_client
      client = Minitest::Mock.new.expect(:call!, Client::Response.new("OK"), [
        "HSET", @document.document_id, ["first", @document.first,
                                        "last", @document.last]
      ].compact, skip_ft: true)

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end
  end
end
