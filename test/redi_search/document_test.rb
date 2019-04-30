# frozen_string_literal: true

require "test_helper"
require "redi_search/document"

module RediSearch
  class DocumentTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("user_idx", first: :text, last: :text)
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
      @record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(@record)

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
      @record1 = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(@record1)
      @record2 = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(@record2)

      docs = RediSearch::Document.mget(@index, @record1.id, @record2.id)
      assert_equal 2, docs.count
      assert_equal @record1.id, docs.first.document_id
      assert_equal @record2.id, docs.second.document_id
    end

    test ".mget when a doc doesnt exist" do
      @record1 = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(@record1)

      docs = RediSearch::Document.mget(@index, @record1.id, "rando")
      assert_equal 1, docs.count
      assert_equal @record1.id, docs.first.document_id
      assert_nil docs.second
    end
  end
end
