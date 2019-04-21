# frozen_string_literal: true

require "test_helper"
require "redi_search"

class RediSearchTest < ActiveSupport::TestCase
  test "index name" do
    assert_equal "user_idx", User.index_name
  end

  test "reindex" do
    assert User.create_index
    assert User.drop_index
  end

  test "only ActiveRecord models are searchable" do
    assert_raises RediSearch::Error do
      class Thing
        include RediSearch
      end
    end
  end
end
