# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class ResultTest < Minitest::Test
      def setup
        search = Search.new(Index.new(:users) do
          text_field :name
          numeric_field :number
        end, "foo")
        @result = Result.new(search, 1, ["users1", %w(name foo number 2)])
      end

      def test_count
        assert_equal 1, @result.count
      end

      def test_size
        assert_equal 1, @result.size
      end

      def test_document_parsing
        assert_equal "users1", @result[0].document_id
        assert_equal "foo", @result[0].name
        assert_equal 2, @result[0].number
      end

      def test_inspect
        assert_equal(
          "[#<RediSearch::Document name: foo, number: 2, document_id: users1>]",
          @result.inspect.to_s
        )
      end
    end
  end
end
