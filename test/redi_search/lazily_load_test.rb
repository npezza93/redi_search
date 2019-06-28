# frozen_string_literal: true

require "test_helper"

module RediSearch
  class LazilyLoadTest < ActiveSupport::TestCase
    test "NotImplementedError is raised if command isnt defined" do
      class TempLazy
        include LazilyLoad
      end

      assert_raises NotImplementedError do
        TempLazy.new.to_a
      end

      RediSearch::LazilyLoadTest.send :remove_const, :TempLazy
    end

    test "NotImplementedError is raised if parse_response isnt defined" do
      index = Index.new("users_test", first: :text, last: :text)
      index.drop
      index.create

      class TempLazy
        include LazilyLoad

        def command
          %w(INFO users_test)
        end
      end

      assert_raises NotImplementedError do
        TempLazy.new.to_a
      end

      index.drop
      RediSearch::LazilyLoadTest.send :remove_const, :TempLazy
    end
  end
end
