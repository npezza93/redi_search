# frozen_string_literal: true

require "redi_search/client"

module RediSearch
  class Configuration
    attr_writer :redis_config

    def client
      @client ||= Client.new(redis_config)
    end

    def redis_config
      @redis_config ||= {
        host: "127.0.0.1", port: "6379", logger: Logger.new(STDOUT)
      }
    end
  end
end
