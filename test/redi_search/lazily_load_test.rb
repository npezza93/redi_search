# frozen_string_literal: true

require "test_helper"

module RediSearch
  class LazilyLoadTest < Minitest::Test
    class TempLazyDouble1
      include LazilyLoad
    end

    class TempLazyDouble2
      include LazilyLoad

      def command
        %w(INFO users_test)
      end
    end

    def test_NotImplementedError_is_raised_if_command_isnt_defined
      assert_raises NotImplementedError do
        TempLazyDouble1.new.to_a
      end
    end

    def test_NotImplementedError_is_raised_if_parse_response_isnt_defined
      index = Index.new("users_test", first: :text, last: :text)
      index.drop
      index.create

      assert_raises NotImplementedError do
        TempLazyDouble2.new.to_a
      end

      index.drop
    end
  end
end
