# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    module Clauses
      class BooleanTest < Minitest::Test
        def test_raises_not_implement_error_until_operand_is_overriden
          index = Index.new(:users) { text_field :first }
          search = Search.new(index, "foo")
          clause = Boolean.new(search, "bar")

          assert_raises NotImplementedError do
            clause.to_s
          end
        end
      end
    end
  end
end
