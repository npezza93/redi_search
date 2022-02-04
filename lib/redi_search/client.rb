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

    def call!(command, *params, skip_ft: false)
      instrument(command.downcase, query: [command, params]) do
        command = "FT.#{command}" unless skip_ft
        send_command(command, *params)
      end
    end

    def multi
      Response.new(redis.multi do |pipeline|
        instrument("pipeline", query: ["begin pipeline"])
        capture_pipeline(pipeline) { yield }
        instrument("pipeline", query: ["finish pipeline"])
      end)
    end

    private

    attr_reader   :redis
    attr_accessor :pipeline

    def capture_pipeline(pipeline)
      self.pipeline = pipeline
      yield
      self.pipeline = false
    end

    def send_command(command, *params)
      if pipeline
        Response.new(pipeline.call(command, *params))
      else
        Response.new(redis.call(command, *params))
      end
    end

    def instrument(action, payload, &block)
      ActiveSupport::Notifications.instrument(
        "action.redi_search",
        { name: "RediSearch", action: action, inside_pipeline: pipeline }.
          merge(payload),
        &Proc.new(&(block || proc {}))
      )
    end
  end
end
