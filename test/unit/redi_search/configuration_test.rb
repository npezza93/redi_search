# frozen_string_literal: true

require "test_helper"

module RediSearch
  class ConfigurationTest < Minitest::Test
    def teardown
      RediSearch.reset
    end

    def test_redis_config_setting
      redis_config = { host: "google.com", port: 199 }

      RediSearch.configure do |config|
        config.redis_config = redis_config
      end

      assert_equal redis_config, RediSearch.configuration.redis_config
    end
  end
end
