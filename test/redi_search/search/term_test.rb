# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Search
    class TermTest < Minitest::Test
      def test_to_s
        assert_equal "`term`", Term.new("term").to_s
      end

      def test_fuzziness_of_1_to_s
        assert_equal "`%term%`", Term.new("term", fuzziness: 1).to_s
      end

      def test_fuzziness_less_than_0_or_greater_than_3_throws_error
        assert_raises RediSearch::ValidationError do
          Term.new("term", fuzziness: -1).to_s
        end
        assert_raises RediSearch::ValidationError do
          Term.new("term", fuzziness: 4).to_s
        end
      end

      def test_escapes_backticks_in_term
        assert_equal "`te\`rm`", Term.new("te`rm").to_s
      end

      def test_unsupported_options_throw_error
        assert_raises RediSearch::ValidationError do
          Term.new("term", random: true)
        end
      end

      def test_support_optional_terms
        assert_equal "`~term`", Term.new("term", optional: true).to_s
      end

      def test_support_prefix_term
        assert_equal "`hel*`", Term.new("hel", prefix: true).to_s
      end
    end
  end
end
