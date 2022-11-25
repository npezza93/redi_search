# frozen_string_literal: true

require "active_support/notifications"

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
      instrument("pipeline", query: ["begin pipeline"])
      Response.new(redis.pipelined do |pipeline|
        capture_pipeline(pipeline) { yield }
      end)
    ensure
      instrument("pipeline", query: ["finish pipeline"])
    end

    private

    attr_reader   :redis
    attr_accessor :pipeline

    def capture_pipeline(pipeline)
      self.pipeline = pipeline
      yield
    ensure
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
