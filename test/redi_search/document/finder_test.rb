# frozen_string_literal: true

require "test_helper"
require "redi_search/document"
require "redi_search/document/finder"

module RediSearch
  class Document
    class FinderTest < Minitest::Test
      include ActiveSupport::Testing::Assertions

      def setup
        @index = Index.new(:users_test, first: :text, last: :text)
        @record = users(index: 0)

        @index.reindex([Document.for_object(@index, @record)], recreate: true)
      end

      def teardown
        @index.drop
      end

      def test_get_with_id_already_prepended
        doc = RediSearch::Document::Finder.new(
          @index,
          "#{@index.name}#{@record.id}"
        ).find

        assert_equal @record.first, doc.first
        assert_equal @record.last, doc.last
        assert_equal @record.id.to_s, doc.document_id_without_index
        assert_equal "users_test#{@record.id}", doc.document_id
      end

      def test_mget_with_id_that_doesnt_exist
        docs = RediSearch::Document::Finder.new(
          @index,
          "#{@index.name}#{@record.id}",
          "#{@index.name}#{@record.id}12"
        ).find

        assert_equal "users_test#{@record.id}", docs.first.document_id
        assert_equal 1, docs.count
      end
    end
  end
end
