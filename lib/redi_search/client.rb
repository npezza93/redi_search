# frozen_string_literal: true

require "redis"
require "active_support/notifications"

require "redi_search/client/response"

module RediSearch
  class Client
    def initialize(redis = Redis.new)
      @redis = redis
      @pipeline = false
    end

    def call!(command, *params)
      instrument(command.downcase, query: [command, params]) do
        send_command(command, *params)
      end
    end

    def multi
      Response.new(redis.multi do
        instrument("pipeline", query: ["begin pipeline"])
        capture_pipeline { yield }
        instrument("pipeline", query: ["finish pipeline"])
      end)
    end

    private

    attr_reader   :redis
    attr_accessor :pipeline

    def capture_pipeline
      self.pipeline = true
      yield
      self.pipeline = false
    end

    def send_command(command, *params)
      Response.new(redis.call("FT.#{command}", *params))
    end

    def instrument(action, payload, &block)
      ActiveSupport::Notifications.instrument(
        "action.redi_search",
        { name: "RediSearch", action: action, inside_pipeline: pipeline }.
          merge(payload),
        &Proc.new(&(block || proc {})) # rubocop:disable Lint/EmptyBlock
      )
    end
  end
end
