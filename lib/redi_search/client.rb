# frozen_string_literal: true

require "redis"
require "active_support/notifications"

require "redi_search/client/response"

module RediSearch
  class Client
    def initialize(redis = Redis.new)
      @redis = redis
    end

    def call!(command, *params)
      instrument(command.downcase, query: [command, params]) do
        send_command(command, *params)
      end
    end

    def pipelined
      Response.new(redis.pipelined do
        instrument("pipeline", query: ["begin pipeline"])
        yield
        instrument("pipeline", query: ["finish pipeline"])
      end)
    end

    private

    attr_reader :redis

    def send_command(command, *params)
      Response.new(redis.call("FT.#{command}", *params))
    end

    def instrument(action, payload, &block)
      ActiveSupport::Notifications.instrument(
        "#{action}.redi_search",
        { name: "RediSearch" }.merge(payload),
        &Proc.new(&(block || proc {}))
      )
    end
  end
end
