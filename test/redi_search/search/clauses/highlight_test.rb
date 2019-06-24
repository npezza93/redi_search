# frozen_string_literal: true

require "test_helper"
require "redi_search/search/clauses/highlight"

module RediSearch
  class Search
    module Clauses
      class HighlightTest < ActiveSupport::TestCase
        setup do
          @clause = RediSearch::Search::Clauses::Highlight
        end

        test "returns HIGHLIGHT keyword" do
          assert_equal ["HIGHLIGHT", "TAGS", "<b>", "</b>"], @clause.new.clause
        end

        test "tags clause" do
          assert_equal(
            ["HIGHLIGHT", "TAGS", "<i>", "</i>"],
            @clause.new(opening_tag: "<i>", closing_tag: "</i>").clause
          )
        end

        test "tags with no opening" do
          assert_raise ArgumentError do
            @clause.new(opening_tag: nil).clause
          end
        end

        test "tags with no closing" do
          assert_raise ArgumentError do
            @clause.new(closing_tag: nil).clause
          end
        end

        test "fields clause" do
          assert_equal(
            ["HIGHLIGHT", "FIELDS", 1, ["name"], "TAGS", "<b>", "</b>"],
            @clause.new(fields: ["name"]).clause
          )
        end

        test "fields is always before tags" do
          assert_equal(
            ["HIGHLIGHT", "FIELDS", 1, ["name"], "TAGS", "<b>", "</b>"],
            @clause.new(
              fields: ["name"], opening_tag: "<b>", closing_tag: "</b>"
            ).clause
          )
        end
      end
    end
  end
end
