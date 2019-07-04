# frozen_string_literal: true

module RediSearch
  class Client
    class Response < SimpleDelegator
      def initialize(response)
        @response = response

        super(response)
      end

      def ok?
        case response
        when String then response == "OK"
        when Integer then response == 1
        when Array then array_ok?
        else
          response
        end
      end

      private

      attr_reader :response

      def array_ok?
        response.all? do |pipeline_response|
          Response.new(pipeline_response).ok?
        end
      end
    end
  end
end
