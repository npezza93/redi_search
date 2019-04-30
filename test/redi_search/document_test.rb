# frozen_string_literal: true

require "test_helper"
require "redi_search/document"

module RediSearch
  class DocumentTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("user_idx", first: :text, last: :text)
      @index.drop
      @index.create
      @record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(@record)
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
      doc = RediSearch::Document.get(@index, @record.id)
      assert_equal @record.first, doc.first
      assert_equal @record.last, doc.last
      assert_equal @record.id, doc.document_id
    end

    test ".get when doc doesnt exist" do
      doc = RediSearch::Document.get(@index, "rando")
      assert_nil doc
    end
  end
end
