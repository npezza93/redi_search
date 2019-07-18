# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class IndexTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
      @index.drop
      @index.create
      @user = User.new(rand, "foo", "bar")
      @document = Document.for_object(@index, @user)
    end

    def teardown
      @index.drop
    end

    def test_add
      assert_difference -> { @index.document_count } do
        @index.add(@document)
      end
    end

    def test_add!
      assert_difference -> { @index.document_count } do
        @index.add(@document)
      end

      assert_raises Redis::CommandError do
        @index.add!(@document)
      end
    end

    def test_del
      @index.add(@document)

      assert_difference -> { @index.document_count }, -1 do
        assert @index.del(@document)
      end
    end

    def test_document_count
      @index.add(@document)

      assert_equal @index.info["num_docs"].to_i, @index.document_count
    end

    def test_create_fails_if_the_index_already_exists
      dup_index = Index.new(:users_test, first: :text, last: :text)

      assert_not dup_index.create
    end

    def test_create_bang_raises_exception_if_the_index_already_exists
      dup_index = Index.new(:users_test, first: :text, last: :text)

      assert_raises Redis::CommandError do
        dup_index.create!
      end
    end

    def test_info_returns_nothing_if_the_index_doesnt_exist
      rando_idx = Index.new(:rando_idx, first: :text, last: :text)

      assert_nil rando_idx.info
    end

    def test_fields
      assert_equal %w(first last), @index.fields
    end

    def test_reindex
      assert_equal 0, @index.info["num_docs"].to_i
      assert @index.reindex([@document])
      assert_equal 1, @index.info["num_docs"].to_i
    end

    def test_search
      assert_difference -> { @index.document_count } do
        @index.add(@document)
      end

      assert_equal 1, @index.search(@user.first).count

      other_user = User.new(rand, "foo", "bar jr")
      assert_difference -> { @index.document_count } do
        @index.add(Document.for_object(@index, other_user))
      end

      assert_equal 2, @index.search(@user.first).count
    end

    def test_Results_size_is_aliased_to_count
      assert_difference -> { @index.document_count } do
        @index.add(@document)
      end

      assert_equal(
        @index.search(@user.first).count, @index.search(@user.first).size
      )
    end

    def test_exists?
      assert @index.exist?
      assert @index.drop
      assert_not @index.exist?
    end
  end
end
