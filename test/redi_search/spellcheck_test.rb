# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class SpellcheckTest < ActiveSupport::TestCase
    setup do
      @index = User.redi_search_index
      User.reindex
    end

    teardown do
      @index.drop
    end

    test "query execution" do
      query = RediSearch::Spellcheck.new(@index, "nic")
      assert_equal Array, query.to_a.class
    end

    test "something is returned" do
      query = @index.spellcheck("nic")
      assert_equal 1, query.to_a.size
    end
  end
end
