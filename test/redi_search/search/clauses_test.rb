# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class ClausesTest < Minitest::Test
      def setup
        @index = Index.new(:users_test, name: :text)
        @index.drop
        @index.create
      end

      def teardown
        @index.drop
      end

      def test_slop_clause
        assert_clause("SLOP 1", stubbed_search.slop(1))
      end

      def test_in_order_clause
        assert_clause("INORDER", stubbed_search.in_order)
      end

      def test_verbatim_clause
        assert_clause("VERBATIM", stubbed_search.verbatim)
      end

      def test_no_stop_words_clause
        assert_clause("NOSTOPWORDS", stubbed_search.no_stop_words)
      end

      def test_language_clause
        assert_clause("LANGUAGE danish", stubbed_search.language("danish"))
      end

      def test_sort_by_clause
        assert_clause("SORTBY first asc", stubbed_search.sort_by(:first))
      end

      def test_sort_by_desc_clause
        assert_clause(
          "SORTBY first desc", stubbed_search.sort_by(:first, order: :desc)
        )
      end

      def test_sort_by_arg_error_with_bad_order
        assert_raises RediSearch::ValidationError do
          stubbed_search.sort_by(:first, order: :random)
        end
      end

      def test_limit_clause_defaults_to_0_offset
        assert_clause("LIMIT [0, 10]", stubbed_search.limit(10))
      end

      def test_limit_clause_with_custom_offset
        assert_clause("LIMIT [5, 10]", stubbed_search.limit(10, 5))
      end

      def test_no_content_just_returns_docs_with_ids
        index_all_users

        refute @index.search("*").no_content.results.empty?
      end

      def test_return_returns_certain_fields
        assert_clause("RETURN 1 name", stubbed_search.return(:name))
      end

      def test_with_scores_clause
        assert_clause("WITHSCORES", stubbed_search.with_scores)
      end

      def test_with_scores_includes_the_score
        index_all_users

        query = RediSearch::Search.new(@index, users(index: 0).first).with_scores

        assert query.first.score > 0.0
      end

      def test_there_are_no_duplicate_clauses
        assert_clause("WITHSCORES", stubbed_search.with_scores.with_scores)
      end

      def test_count_when_loaded
        search = stubbed_search
        search.load

        assert search.is_a? Search
        assert search.count >= 0
      end

      def test_count_when_loaded_on_the_result_set
        results = stubbed_search.load

        assert results.is_a? Search::Result
        assert results.count >= 0
      end

      private

      Name = Struct.new(:name) do
        def id
          SecureRandom.hex
        end
      end

      def index_all_users
        users(index: 0..-1).each do |user|
          @index.add Document.for_object(@index, Name.new(user.first))
        end
      end

      def stubbed_search
        RediSearch::Search.new(@index, "dr")
      end

      def assert_clause(expected_clause, query)
        assert_equal(
          "SEARCH users_test `dr` #{expected_clause}", query.to_redis
        )
      end
    end
  end
end
