# frozen_string_literal: true

require "test_helper"
require "redi_search"

class RediSearchTest < Minitest::Test
  def test_env_is_dev_by_default
    assert_equal "development", RediSearch.env
  end
end
