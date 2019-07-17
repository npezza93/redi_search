# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class SpellcheckTest < Minitest::Test
    def setup
      @index = User.redi_search_index
      User.reindex
    end

    def teardown
      @index.drop
    end

    def test_query_execution
      query = RediSearch::Spellcheck.new(@index, "nic")
      assert_equal Array, query.to_a.class
    end

    def test_something_is_returned
      query = @index.spellcheck("nic")
      assert_equal 1, query.to_a.size
    end

    def test_raises_validation_error_when_distance_is_to_large
      assert_raises RediSearch::ValidationError do
        @index.spellcheck("nic", distance: 10).to_a
      end
    end

    def test_raises_validation_error_when_distance_is_too_specific
      assert_raises RediSearch::ValidationError do
        @index.spellcheck("nic", distance: 3.5).to_a
      end
    end
  end
end
