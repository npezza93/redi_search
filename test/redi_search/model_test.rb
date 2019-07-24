# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ModelTest < Minitest::Test
    def teardown
      User.redi_search_index.drop
    end

    def test_index_name
      assert_equal "users_test", User.redi_search_index.name
    end

    def test_reindex
      assert User.redi_search_index.create
      assert User.redi_search_index.drop
    end

    def test_adds_document_when_a_record_is_created
      assert User.reindex

      assert_difference -> { User.redi_search_index.info.num_docs.to_i }, 1 do
        User.create(first: "foo", last: "bar")
      end
    end

    def test_removes_document_when_a_record_is_destroyed
      assert User.reindex

      assert_difference -> { User.redi_search_index.info.num_docs.to_i }, -1 do
        User.last.destroy
      end
    end

    def test_using_a_serializer
      document = characters(:tywin).redi_search_document

      assert_equal "Tywin Lannister", document.name
    end

    def test_setting_an_index_prefix
      assert_equal "example_superpowers_test", Superpower.redi_search_index.name
    end

    def test_responds_to_spellcheck
      assert User.reindex
      assert_equal 1, User.spellcheck("fli").count
    end

    def test_calling_results_on_search_results_looks_up_AR_records
      assert User.reindex
      user = users(:nick)
      search_results = User.search("nick")

      assert search_results.count.positive?
      assert_includes search_results.results, user
    end
  end
end
