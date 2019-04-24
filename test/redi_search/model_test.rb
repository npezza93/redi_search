# frozen_string_literal: true

require "test_helper"
require "redi_search"

module RediSearch
  class ModelTest < ActiveSupport::TestCase
    test "index name" do
      assert_equal "user_idx", User.redi_search_index.name
    end

    test "reindex" do
      assert User.redi_search_index.create
      assert User.redi_search_index.drop
    end
  end
end
