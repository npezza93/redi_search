# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SearchTest < Minitest::Test
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

    def test_explain
      assert_match(
        /UNION {\s*first_name\s*\+first_nam\(expanded\)\s*first_nam\(expanded\) }/, # rubocop:disable Layout/LineLength
        Search.new(@index, "first_name").explain
      )
    end
  end
end
