# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class IndexTest < Minitest::Test
    def setup
      @index = Index.new("users_test", first: :text, last: :text)
      @index.drop
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_add
      assert_difference -> { User.redi_search_index.document_count } do
        @index.add(users(:nick).redi_search_document)
      end
    end

    def test_add!
      assert_difference -> { User.redi_search_index.document_count } do
        @index.add(users(:nick).redi_search_document)
      end

      assert_raises Redis::CommandError do
        @index.add!(users(:nick).redi_search_document)
      end
    end

    def test_del
      @index.add(users(:nick).redi_search_document)

      assert_difference -> { User.redi_search_index.document_count }, -1 do
        assert @index.del(users(:nick).redi_search_document)
      end
    end

    def test_document_count
      @index.add(users(:nick).redi_search_document)

      assert_equal @index.info["num_docs"].to_i, @index.document_count
    end

    def test_create_fails_if_the_index_already_exists
      dup_index = Index.new("users_test", first: :text, last: :text)

      assert_not dup_index.create
    end

    def test_create_bang_raises_exception_if_the_index_already_exists
      dup_index = Index.new("users_test", first: :text, last: :text)

      assert_raises Redis::CommandError do
        dup_index.create!
      end
    end

    def test_info_returns_nothing_if_the_index_doesnt_exist
      rando_idx = Index.new("rando_idx", first: :text, last: :text)

      assert_nil rando_idx.info
    end

    def test_fields
      assert_equal %w(first last), @index.fields
    end

    def test_reindex
      assert_equal 0, @index.info["num_docs"].to_i
      assert @index.reindex(User.all.map(&:redi_search_document))
      assert_equal User.count, @index.info["num_docs"].to_i
    end

    def test_search
      assert_difference -> { User.redi_search_index.document_count } do
        @record = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      assert_equal 1, @index.search(@record.first).count

      @record_jr = @record.dup
      @record_jr.last = @record_jr.last + " jr"
      assert_difference -> { User.redi_search_index.document_count } do
        @record_jr.save
      end

      assert_equal 2, @index.search(@record.first).count
    end

    def test_Results_size_is_aliased_to_count
      assert_difference -> { User.redi_search_index.document_count } do
        @record = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      assert_equal(
        @index.search(@record.first).count, @index.search(@record.first).size
      )
    end

    def test_exists?
      assert @index.exist?
      assert @index.drop
      assert_not @index.exist?
    end
  end
end
