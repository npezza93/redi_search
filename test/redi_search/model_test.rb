# frozen_string_literal: true

require "test_helper"
require "redi_search"

class Superpower < ApplicationRecord
  redi_search index_prefix: :example
end

module RediSearch
  class ModelTest < ActiveSupport::TestCase
    teardown do
      User.redi_search_index.drop
    end

    test "index name" do
      assert_equal "users_test", User.redi_search_index.name
    end

    test "reindex" do
      assert User.redi_search_index.create
      assert User.redi_search_index.drop
    end

    test "adds document when a record is created" do
      assert User.reindex

      assert_difference -> { User.redi_search_index.info.num_docs.to_i }, 1 do
        User.create(first: "foo", last: "bar")
      end
    end

    test "removes document when a record is destroyed" do
      assert User.reindex

      assert_difference -> { User.redi_search_index.info.num_docs.to_i }, -1 do
        User.last.destroy
      end
    end

    test "using a serializer" do
      document = characters(:tywin).redi_search_document

      assert_equal "Tywin Lannister", document.name
    end

    test "setting an index prefix" do
      assert_equal "example_superpowers_test", Superpower.redi_search_index.name
    end
  end
end
