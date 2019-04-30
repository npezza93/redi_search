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
  end
end
