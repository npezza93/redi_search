# frozen_string_literal: true

require "test_helper"
require "redi_search/spellcheck"

module RediSearch
  class Spellcheck
    class ResultTest < Minitest::Test
      def test_inspect
        inspection = Result.new("foo", [["0.5", "foob"]]).inspect
        expected_inspection = "#<RediSearch::Spellcheck::Result term: foo, "\
                              "suggestions: [#<struct RediSearch::Spellcheck::Suggestion score=0.5,"\
                              " suggestion=\"foob\">]>"

        assert_equal expected_inspection, inspection
      end
    end
  end
end
