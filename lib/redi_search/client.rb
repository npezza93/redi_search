# frozen_string_literal: true

require "redis"

module RediSearch
  class Client
    class Response < SimpleDelegator
      def initialize(response)
        @response = response

        super(response)
      end

      def ok?
        if response.is_a? String
          response == "OK"
        elsif response.is_a? Array
          response.all? { |pipeline_response| pipeline_response == "OK" }
        else
          response
        end
      end

      private

      attr_reader :response
    end

    def initialize(redis_config)
      @redis = Redis.new(redis_config)
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

    def instrument(action, payload)
      block =
        if block_given?
          Proc.new
        else
          proc {}
        end

      ActiveSupport::Notifications.instrument(
        "#{action}.redi_search", { name: "RediSearch" }.merge(payload), &block
      )
    end
  end
end
