# frozen_string_literal: true

require "test_helper"

module RediSearch
  class AddTest < Minitest::Test
    include ActiveSupport::Testing::Assertions

    def setup
      @index = Index.new(:users_test, first: :text, last: :text)
      @document = Document.for_object(@index, users(index: 0))
      @index.recreate
    end

    def teardown
      @index.drop
    end

    def test_adds_document_to_index
      assert_difference -> { @index.document_count }, 1 do
        assert Add.new(@index, @document).call
      end
    end

    def test_replace_partial_clause
      assert_difference -> { @index.document_count }, 1 do
        assert Add.new(@index, @document, replace: { partial: true }).call
      end
    end

    def test_replace_clause
      assert_difference -> { @index.document_count }, 1 do
        assert Add.new(@index, @document, replace: true).call
      end
    end

    def test_no_save_clause
      assert_difference -> { @index.document_count }, 1 do
        assert Add.new(@index, @document, no_save: true).call
      end
    end
  end
end
