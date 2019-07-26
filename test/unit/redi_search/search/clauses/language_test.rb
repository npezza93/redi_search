# frozen_string_literal: true

require "test_helper"
require "redi_search/search"

module RediSearch
  class Search
    module Clauses
      class LanguageTest < Minitest::Test
        def setup
          @clause = Language
        end

        def test_clause
          assert_equal %w(LANGUAGE en), @clause.new(language: "en").clause
        end
      end
    end
  end
end
