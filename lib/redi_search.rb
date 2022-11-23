# frozen_string_literal: true

require "delegate"
require "forwardable"
require "redis_client"
require "active_support/lazy_load_hooks"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module RediSearch
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= Client.new(RedisClient.new(configuration.redis_config.to_h))
    end

    def env
      ENV.fetch("RAILS_ENV") { ENV.fetch("RACK_ENV", "development") }
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include RediSearch::Model
end
RediSearch::LogSubscriber.attach_to :redi_search
