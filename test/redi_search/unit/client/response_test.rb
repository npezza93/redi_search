# frozen_string_literal: true

require "test_helper"
require "redi_search/client"

module RediSearch
  class Client
    class ResponseTest < Minitest::Test
      def test_ok_with_string
        assert Response.new("OK").ok?
      end

      def test_not_ok_when_string_not_ok
        refute Response.new("NOTOK").ok?
      end

      def test_ok_with_array
        assert Response.new(%w(OK OK)).ok?
      end

      def test_array_not_ok_if_any_are_not_ok
        refute Response.new(%w(OK NOTOK)).ok?
      end

      def test_ok_with_other_object
        assert Response.new({ thing: 1 }).ok?
        assert_equal({ thing: 1 }, Response.new({ thing: 1 }).ok?)
      end
    end
  end
end
