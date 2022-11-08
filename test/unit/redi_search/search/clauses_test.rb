# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class ClausesTest < Minitest::Test
      def setup
        @search = Search.new(Index.new(:users) { text_field :name }, "foo")
      end

      def test_highlight
        @search.highlight

        assert_includes @search.used_clauses, Search::Highlight
      end

      def test_slop
        @search.slop(1)

        assert_includes @search.used_clauses, Search::Slop
      end

      def test_in_order
        @search.in_order

        assert_includes @search.used_clauses, Search::InOrder
      end

      def test_verbatim
        @search.verbatim

        assert_includes @search.used_clauses, Search::Verbatim
      end

      def test_no_stop_words
        @search.no_stop_words

        assert_includes @search.used_clauses, Search::NoStopWords
      end

      def test_with_scores
        @search.with_scores

        assert_includes @search.used_clauses, Search::WithScores
      end

      def test_no_content
        @search.no_content

        assert_includes @search.used_clauses, Search::NoContent
      end

      def test_return
        @search.return(:name)

        assert_includes @search.used_clauses, Search::Return
      end

      def test_language
        @search.language("chinese")

        assert_includes @search.used_clauses, Search::Language
      end

      def test_sort_by
        @search.sort_by(:first)

        assert_includes @search.used_clauses, Search::SortBy
      end

      def test_limit
        @search.limit(10)

        assert_includes @search.used_clauses, Search::Limit
      end

      def test_there_are_no_duplicate_clauses
        @search.with_scores.with_scores

        assert_equal 1, @search.clauses.count
      end

      def test_count_when_loaded
        client = Minitest::Mock.new.expect(
          :call!, Client::Response.new([1]), ["SEARCH", "users", "`foo`"]
        )

        assert_result_count(client) do
          @search.load
        end
      end

      def test_count_when_not_yet_loaded
        client = Minitest::Mock.new.expect(
          :call!, Client::Response.new([1]),
          ["SEARCH", "users", "`foo`", "LIMIT", 0, 0]
        )

        assert_result_count(client)
      end

      def test_where_without_terms_returns_the_clause_to_be_chained
        assert_instance_of Search::Where, @search.where
      end

      def test_and_without_terms_returns_the_clause_to_be_chained
        assert_instance_of Search::And, @search.and
      end

      def test_or_without_terms_returns_the_clause_to_be_chained
        assert_instance_of Search::Or, @search.or
      end

      private

      def assert_result_count(client)
        RediSearch.stub(:client, client) do
          yield if block_given?

          assert_equal 1, @search.count
        end

        assert_mock client
      end
    end
  end
end
