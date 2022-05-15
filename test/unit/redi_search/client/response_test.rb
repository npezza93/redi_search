# frozen_string_literal: true

require "test_helper"

module RediSearch
  class Client
    class ResponseTest < Minitest::Test
      def test_ok_with_string
        assert_predicate Response.new("OK"), :ok?
      end

      def test_not_ok_when_string_not_ok
        refute_predicate Response.new("NOTOK"), :ok?
      end

      def test_ok_with_array
        assert_predicate Response.new(%w(OK OK)), :ok?
      end

      def test_array_not_ok_if_any_are_not_ok
        refute_predicate Response.new(%w(OK NOTOK)), :ok?
      end

      def test_ok_with_other_object
        assert_predicate Response.new({ thing: 1 }), :ok?
        assert_equal({ thing: 1 }, Response.new({ thing: 1 }).ok?)
      end
    end
  end
end
