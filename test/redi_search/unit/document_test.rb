# frozen_string_literal: true

require "test_helper"

module RediSearch
  class DocumentTest < Minitest::Test
    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
    end

    def test_initialize
      document = Document.new(@index, 100, { first: :foo, last: :bar })
      assert_equal :foo, document.first
      assert_equal :bar, document.last
    end

    def test_document_id_with_already_prepended_index_name
      document = Document.new(
        @index, @index.name + "100", { first: :foo, last: :bar }
      )

      assert_equal "users_test100", document.document_id
    end

    def test_document_id
      document = Document.new(@index, 100, { first: :foo, last: :bar })

      assert_equal "users_test100", document.document_id
    end

    def test_document_id_without_index
      document = Document.new(@index, 100, { first: :foo, last: :bar })

      assert_equal 100, document.document_id_without_index
    end

    def test_document_id_without_index_when_already_prepended
      document = Document.new(
        @index, @index.name + "100", { first: :foo, last: :bar }
      )

      assert_equal "100", document.document_id_without_index
    end

    def test_redis_attributes
      document = Document.new(@index, 100, { first: :foo, last: :bar })

      assert_equal %i(first foo last bar), document.redis_attributes
    end

    def test_schema_fields
      document = Document.new(@index, 100, { first: :foo, last: :bar })

      assert_equal %w(first last), document.schema_fields
    end

    def test_del
      document = Document.new(@index, 100, { first: :foo, last: :bar })
      mock_client(document, 1) do
        assert document.del
      end
    end

    def test_del_that_deletes_document
      document = Document.new(@index, 100, { first: :foo, last: :bar })
      mock_client(document, 1, "DD") do
        assert document.del(delete_document: true)
      end
    end

    def test_failed_del
      document = Document.new(@index, 100, { first: :foo, last: :bar })
      mock_client(document, 0) do
        refute document.del
      end
    end

    def test_for_object
      document = Document.for_object(@index, users(index: 0))

      assert_equal "users_test1", document.document_id
    end

    def test_for_object_only
      document = Document.for_object(@index, users(index: 0), only: %i(first))

      assert_equal "users_test1", document.document_id
      refute_respond_to document, :last
    end

    def test_for_object_serializer
      index = Index.new(:users_test, name: :text)
      document =
        Document.for_object(index, users(index: 0), serializer: UserSerializer)

      assert_equal "users_test1", document.document_id
      refute_respond_to document, :first
      assert_respond_to document, :name
    end

    private

    def mock_client(document, response, *options)
      client = Minitest::Mock.new.expect(
        :call!, Client::Response.new(response), ["DEL", @index.name,
                                                 document.document_id, *options]
      )

      RediSearch.stub(:client, client) { yield }
      assert_mock client
    end
  end
end
