require "test_helper"

# frozen_string_literal: true

module RediSearch
  class Search
    class TermTest < ActiveSupport::TestCase
      test "#to_s" do
        assert_equal "`term`", Term.new("term").to_s
      end

      test "fuzziness of 1 #to_s" do
        assert_equal "`%term%`", Term.new("term", fuzziness: 1).to_s
      end

      test "fuzziness < 0 || > 3 throws error" do
        assert_raise ArgumentError do
          Term.new("term", fuzziness: -1).to_s
        end
        assert_raise ArgumentError do
          Term.new("term", fuzziness: 4).to_s
        end
      end

      test "escapes backticks in term" do
        assert_equal "`te\`rm`", Term.new("te`rm").to_s
      end
    end
  end
end
