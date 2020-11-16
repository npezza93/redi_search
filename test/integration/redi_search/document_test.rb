# frozen_string_literal: true

require "test_helper"

module RediSearch
  class DocumentTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @index.create
      @index.add(Document.for_object(@index, users(index: 0)))
    end

    def teardown
      @index.drop
    end

    def test_del
      assert_difference -> { @index.document_count }, -1 do
        Document.for_object(@index, users(index: 0)).del
      end
    end
  end
end
