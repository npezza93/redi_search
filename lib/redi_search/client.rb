# frozen_string_literal: true

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

    def initialize(redis_instance)
      @redis_instance = redis_instance
    end

    def call!(command, *params)
      send_command(command, *params)
    end

    def pipelined
      Response.new(redis_instance.pipelined { yield })
    end

    private

    attr_reader :redis_instance

    def send_command(command, *params)
      Response.new(redis_instance.call("FT.#{command}", *params))
    end
  end
end
