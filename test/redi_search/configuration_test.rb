# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ConfigurationTest < ActiveSupport::TestCase
    teardown do
      RediSearch.reset
    end

    test "#redis_config=" do
      redis_config = {
        host: "google.com", port: 199
      }

      RediSearch.configure do |config|
        config.redis_config = redis_config
      end

      assert_equal redis_config, RediSearch.configuration.redis_config
    end
  end
end
