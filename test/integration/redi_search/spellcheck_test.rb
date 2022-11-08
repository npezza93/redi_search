# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SpellcheckTest < Minitest::Test
    def setup
      @index = Index.new(:users) do
        text_field :first
        text_field :last
      end.tap(&:create)
      @index.add(Document.for_object(@index, users(index: 0)))
    end

    def teardown
      @index.drop
    end

    def test_query_execution
      suggestions = Spellcheck.new(@index, "first_name").load

      assert_equal 1, suggestions.size
      assert_equal "first_name", suggestions.first.term
      assert_equal 1, suggestions.first.suggestions.size
    end
  end
end
