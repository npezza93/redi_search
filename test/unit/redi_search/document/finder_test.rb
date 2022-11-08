# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Document
    class FinderTest < Minitest::Test
      def setup
        @index = Index.new(:users) do
          text_field :first
          text_field :last
        end
      end

      def test_get_with_id
        finder = Document::Finder.new(@index, 1)

        mock_client("HGETALL", default_response, "#{@index.name}1") do
          document = finder.find

          assert_equal "#{@index.name}1", document.document_id
        end
      end

      def test_get_with_id_when_not_found
        finder = Document::Finder.new(@index, 1)

        mock_client("HGETALL", nil, "#{@index.name}1") do
          assert_nil finder.find
        end
      end

      def test_get_with_id_already_prepended
        finder = Document::Finder.new(@index, "#{@index.name}1")

        mock_client("HGETALL", default_response, "#{@index.name}1") do
          document = finder.find

          assert_equal "#{@index.name}1", document.document_id
        end
      end

      private

      def mock_client(command, response, id)
        client = Minitest::Mock.new.expect(
          :call!, Client::Response.new(response),
          [command, id].compact, skip_ft: true
        )

        RediSearch.stub(:client, client) { yield }

        assert_mock client
      end

      def default_response(id = 1)
        ["first", "first_name#{id}", "last", "last_name#{id}"]
      end

      def assert_documents(documents, size:, ids:)
        assert_equal size, documents.size
        Array(documents).each_with_index do |document, i|
          assert_equal "#{@index.name}#{ids[i]}", document.document_id
        end
      end
    end
  end
end
