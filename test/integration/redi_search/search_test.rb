# frozen_string_literal: true

require "test_helper"

module RediSearch
  class SearchTest < Minitest::Test
    def setup
      @index = Index.new(:users, first: :text, last: :text)
      @index.create
      @index.add(Document.for_object(@index, users(index: 0)))
    end

    def teardown
      @index.drop
    end

    def test_explain
      assert_equal(
        "UNION { first_name +first_nam(expanded) first_nam(expanded) }",
        Search.new(@index, "first_name").explain
      )
    end
  end
end
