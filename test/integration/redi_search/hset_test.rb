# frozen_string_literal: true

require "test_helper"

module RediSearch
  class HsetTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @document = Document.for_object(@index, users(index: 0))
      @index.create
    end

    def teardown
      @index.drop
    end

    def test_adds_document_to_index
      assert_difference -> { @index.document_count }, 1 do
        assert Hset.new(@index, @document).call
      end
    end
  end
end
