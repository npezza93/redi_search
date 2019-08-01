# frozen_string_literal: true

require "test_helper"
require "redi_search"

class RediSearchTest < Minitest::Test
  def test_env_is_dev_by_default
    ENV["RAILS_ENV"] = ENV["RACK_ENV"] = nil
    assert_equal "development", RediSearch.env
    ENV["RAILS_ENV"] = ENV["RACK_ENV"] = "test"
  end
end
