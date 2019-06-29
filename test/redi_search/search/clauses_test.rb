# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class ClausesTest < ActiveSupport::TestCase
      setup do
        @index = Index.new("users_test", name: :text)
        @index.drop
        @index.create
      end

      teardown do
        @index.drop
      end

      test "slop clause" do
        assert_clause("SLOP 1", stubbed_search.slop(1))
      end

      test "#in_order clause" do
        assert_clause("INORDER", stubbed_search.in_order)
      end

      test "#verbatim clause" do
        assert_clause("VERBATIM", stubbed_search.verbatim)
      end

      test "#no_stop_words clause" do
        assert_clause("NOSTOPWORDS", stubbed_search.no_stop_words)
      end

      test "#language clause" do
        assert_clause("LANGUAGE danish", stubbed_search.language("danish"))
      end

      test "#sort_by clause" do
        assert_clause("SORTBY first asc", stubbed_search.sort_by(:first))
      end

      test "#sort_by desc clause" do
        assert_clause(
          "SORTBY first desc", stubbed_search.sort_by(:first, order: :desc)
        )
      end

      test "#sort_by arg error with bad order" do
        assert_raise ActiveModel::ValidationError do
          stubbed_search.sort_by(:first, order: :random)
        end
      end

      test "#limit clause defaults to 0 offset" do
        assert_clause("LIMIT [0, 10]", stubbed_search.limit(10))
      end

      test "#limit clause with custom offset" do
        assert_clause("LIMIT [5, 10]", stubbed_search.limit(10, 5))
      end

      test "no_content just returns docs with ids" do
        index_all_users

        assert_nothing_raised do
          assert_not @index.search("*").no_content.results.empty?
        end
      end

      test "#return returns certain fields" do
        assert_clause("RETURN 1 name", stubbed_search.return(:name))
      end

      test "#with_scores clause" do
        assert_clause("WITHSCORES", stubbed_search.with_scores)
      end

      test "#with_scores includes the score" do
        index_all_users

        query = RediSearch::Search.new(@index, User.first.first).with_scores

        assert query.first.score > 0.0
      end

      test "there are no duplicate clauses" do
        assert_clause("WITHSCORES", stubbed_search.with_scores.with_scores)
      end

      private

      Name = Struct.new(:name) do
        def id
          SecureRandom.hex
        end
      end

      def index_all_users
        User.find_each do |user|
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
