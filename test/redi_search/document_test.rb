# frozen_string_literal: true

require "test_helper"
require "redi_search/document"

module RediSearch
  class DocumentTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
      @index.drop
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_initialize
      doc = RediSearch::Document.new(
        @index, "100", { "first" => "F", "last" => "L" }
      )
      assert_equal "F", doc.first
      assert_equal "L", doc.last
      assert_equal "#{@index.name}100", doc.document_id
      assert_equal "100", doc.document_id_without_index
    end

    def test_get_class_method
      assert_difference -> { @index.document_count } do
        @record = users(index: 0)
        @index.add(Document.for_object(@index, @record))
      end

      doc = RediSearch::Document.get(@index, @record.id)
      assert_equal @record.first, doc.first
      assert_equal @record.last, doc.last
      assert_equal @record.id, doc.document_id_without_index
      assert_equal "users_test#{@record.id}", doc.document_id
    end

    def test_get_class_method_when_doc_doesnt_exist
      doc = RediSearch::Document.get(@index, "rando")
      assert_nil doc
    end

    def test_mget_class_method
      assert_difference -> { @index.document_count }, 2 do
        @record1 = users(index: 0)
        @record2 = users(index: 1)
        @index.add(Document.for_object(@index, @record1))
        @index.add(Document.for_object(@index, @record2))
      end

      docs = RediSearch::Document.mget(@index, @record1.id, @record2.id)
      assert_equal 2, docs.count
      assert_equal @record1.id, docs[0].document_id_without_index
      assert_equal @record2.id, docs[1].document_id_without_index
    end

    def test_mget_class_method_when_a_doc_doesnt_exist
      assert_difference -> { @index.document_count } do
        @record = users(index: 0)
        @index.add(Document.for_object(@index, @record))
      end

      docs = RediSearch::Document.mget(@index, @record.id, "rando")
      assert_equal 1, docs.count
      assert_equal @record.id, docs[0].document_id_without_index
      assert_nil docs[1]
    end

    def test_del
      assert_difference -> { @index.document_count } do
        @record = users(index: 0)
        @index.add(Document.for_object(@index, @record))
      end

      doc = RediSearch::Document.get(@index, @record.id)
      assert doc.del
      assert_equal 0, @index.info["num_docs"].to_i
    end

    def test_document_id_with_index_name
      attrs = { first: "foo", last: "bar" }

      document = RediSearch::Document.new(@index, @index.name + "100", attrs)

      assert_equal "users_test100", document.document_id
    end
  end
end
