# frozen_string_literal: true

require "test_helper"

module RediSearch
  class CreateTest < Minitest::Test
    def setup
      @index = Index.new(:users) do
        text_field :first
        text_field :last
      end
    end

    def test_creates_index
      mock_client do
        assert Create.new(@index, @index.schema, {}).call
      end
    end

    def test_if_call_fails_false_is_returned
      mock_exceptional_client do
        refute Create.new(@index, @index.schema, {}).call
      end
    end

    def test_call_bang_raises_the_error_to_the_consumer
      mock_exceptional_client do
        assert_raises RedisClient::CommandError do
          Create.new(@index, @index.schema, {}).call!
        end
      end
    end

    def test_max_text_fields_option
      mock_client("MAXTEXTFIELDS") do
        assert Create.new(@index, @index.schema, max_text_fields: true).call
      end
    end

    def test_no_offsets_option
      mock_client("NOOFFSETS") do
        assert Create.new(@index, @index.schema, no_offsets: true).call
      end
    end

    def test_temporary_option
      mock_client("TEMPORARY", 2000) do
        assert Create.new(@index, @index.schema, temporary: 2000).call
      end
    end

    def test_no_highlight_option
      mock_client("NOHL") do
        assert Create.new(@index, @index.schema, no_highlight: true).call
      end
    end

    def test_no_fields_option
      mock_client("NOFIELDS") do
        assert Create.new(@index, @index.schema, no_fields: true).call
      end
    end

    def test_no_frequencies_option
      mock_client("NOFREQS") do
        assert Create.new(@index, @index.schema, no_frequencies: true).call
      end
    end

    def test_multiple_options
      mock_client("NOHL", "NOFIELDS", "NOFREQS") do
        assert Create.new(
          @index, @index.schema,
          no_highlight: true, no_fields: true, no_frequencies: true
        ).call
      end
    end

    private

    def mock_exceptional_client
      Client.new.
        stub :call!, ->(*) { raise RedisClient::CommandError } do |client|
          RediSearch.stub(:client, client) { yield }
        end
    end

    def command(*options)
      [
        "CREATE", @index.name, "ON", "HASH", "PREFIX", 1, @index.name, *options,
        "SCHEMA",
        ["first", "TEXT", "WEIGHT", 1.0, "last", "TEXT", "WEIGHT", 1.0]
      ]
    end

    def mock_client(*options)
      client = Minitest::Mock.new.expect(:call!, Client::Response.new("OK"),
                                         command(*options).compact)

      RediSearch.stub(:client, client) { yield }

      assert_mock client
    end
  end
end
