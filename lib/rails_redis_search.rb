# frozen_string_literal: true

require "active_support/core_ext"
require "active_support/concern"
require "active_record/base"
require "redis"

require "rails_redis_search/railtie"
require "rails_redis_search/error"
require "rails_redis_search/version"

module RailsRedisSearch
  extend ActiveSupport::Concern

  def self.included(other_class)
    return if other_class <= ActiveRecord::Base

    raise RailsRedisSearch::Error,
          "Not included in an ActiveRecord backed class"
  end

  class_methods do
    attr_reader :index_name, :redis

    def searchable(schema:, index_name: name.underscore + "_idx")
      @schema = schema
      @index_name = index_name
      @redis = Redis.new(host: "127.0.0.1", port: "6379")

      define_singleton_method :create_index do
        redis.call("FT.CREATE", @index_name, "SCHEMA", @schema.to_a.flatten)
      end

      define_singleton_method :drop_index do
        redis.call("FT.DROP", @index_name)
      end
    end
  end
end
