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
      ActiveSupport::Notifications.instrument(
        "#{command.downcase}.redi_search",
        { name: "RediSearch", query: [command, params] }
      ) do
        send_command(command, *params)
      end
    end

    def pipelined
      Response.new(redis.pipelined { yield })
    end

    private

    attr_reader :redis

    def send_command(command, *params)
      Response.new(redis.call("FT.#{command}", *params))
    end
  end
end
