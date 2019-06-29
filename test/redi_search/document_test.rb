# frozen_string_literal: true

require "test_helper"
require "redi_search/document"

module RediSearch
  class DocumentTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("users_test", first: :text, last: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "#initialize" do
      doc = RediSearch::Document.new(
        @index, "100", { "first" => "F", "last" => "L" }
      )
      assert_equal "F", doc.first
      assert_equal "L", doc.last
      assert_equal "100", doc.document_id
    end

    test ".get" do
      assert_difference -> { User.redi_search_index.document_count } do
        @record = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      doc = RediSearch::Document.get(@index, @record.id)
      assert_equal @record.first, doc.first
      assert_equal @record.last, doc.last
      assert_equal @record.id, doc.document_id
    end

    test ".get when doc doesnt exist" do
      doc = RediSearch::Document.get(@index, "rando")
      assert_nil doc
    end

    test ".mget" do
      assert_difference -> { User.redi_search_index.document_count }, 2 do
        @record1 = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
        @record2 = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      docs = RediSearch::Document.mget(@index, @record1.id, @record2.id)
      assert_equal 2, docs.count
      assert_equal @record1.id, docs.first.document_id
      assert_equal @record2.id, docs.second.document_id
    end

    test ".mget when a doc doesnt exist" do
      assert_difference -> { User.redi_search_index.document_count } do
        @record1 = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      docs = RediSearch::Document.mget(@index, @record1.id, "rando")
      assert_equal 1, docs.count
      assert_equal @record1.id, docs.first.document_id
      assert_nil docs.second
    end

    test "#del" do
      assert_difference -> { User.redi_search_index.document_count } do
        @record1 = User.create(
          first: Faker::Name.first_name, last: Faker::Name.last_name
        )
      end

      doc = RediSearch::Document.get(@index, @record1.id)
      assert doc.del
      assert_equal 0, @index.info["num_docs"].to_i
    end
  end
end
