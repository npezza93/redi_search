# frozen_string_literal: true

require "redis"

require "redi_search/configuration"

require "redi_search/railtie"
require "redi_search/index"

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
  end

  class << self
    attr_reader :index_name, :redis

    def redi_search(**options)
      cattr_accessor(
        :index_name,
        default: (options[:index_name] || name.underscore + "_idx").to_s
      )
      cattr_accessor :schema, default: Schema.new(options[:schema])

      @redis = Redis.new(host: "127.0.0.1", port: "6379")

      define_singleton_method :create_index do
        redis.call("FT.CREATE", index_name, "SCHEMA", schema.to_a)
      end

      define_singleton_method :drop_index do
        redis.call("FT.DROP", index_name)
      end
    end
  end
end
