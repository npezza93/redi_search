# frozen_string_literal: true

require "test_helper"
require "redi_search/document"

module RediSearch
  class Document
    class FinderTest < Minitest::Test
      def setup
        @index = Index.new(:users, first: :text, last: :text)
      end

      def test_get_with_id
        finder = Document::Finder.new(@index, 1)

        mock_client("GET", default_response, "#{@index.name}1") do
          document = finder.find
          assert_equal "#{@index.name}1", document.document_id
        end
      end

      def test_get_with_id_when_not_found
        finder = Document::Finder.new(@index, 1)

        mock_client("GET", nil, "#{@index.name}1") do
          assert_nil finder.find
        end
      end

      def test_get_with_id_already_prepended
        finder = Document::Finder.new(@index, "#{@index.name}1")

        mock_client("GET", default_response, "#{@index.name}1") do
          document = finder.find
          assert_equal "#{@index.name}1", document.document_id
        end
      end

      def test_mget_with_ids
        response = [default_response(1), default_response(2)]
        mock_client("MGET", response, "#{@index.name}1", "#{@index.name}2") do
          finder = Document::Finder.new(@index, 1, 2)
          assert_documents(finder.find, size: 2, ids: [1, 2])
        end
      end

      def test_mget_with_prepended_ids
        finder =
          Document::Finder.new(@index, "#{@index.name}1", "#{@index.name}2")
        response = [default_response(1), default_response(2)]

        mock_client("MGET", response, "#{@index.name}1", "#{@index.name}2") do
          assert_documents(finder.find, size: 2, ids: [1, 2])
        end
      end

      def test_mget_when_a_document_isnt_found
        finder = Document::Finder.new(@index, 1, 2)
        response = [default_response, nil]

        mock_client("MGET", response, "#{@index.name}1", "#{@index.name}2") do
          assert_documents(finder.find, size: 1, ids: [1])
        end
      end

      private

      def mock_client(command, response, *ids)
        client = Minitest::Mock.new.expect(
          :call!, Client::Response.new(response),
          [command, @index.name, *ids].compact
        )

        RediSearch.stub(:client, client) { yield }

        assert_mock client
      end

      def default_response(id = 1)
        ["first", "first_name#{id}", "last", "last_name#{id}"]
      end

      def assert_documents(documents, size:, ids:)
        assert_equal size, documents.size
        [*documents].each_with_index do |document, i|
          assert_equal "#{@index.name}#{ids[i]}", document.document_id
        end
      end
    end
  end
end
