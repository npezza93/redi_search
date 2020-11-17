# frozen_string_literal: true

module RediSearch
  class Client
    class Response < SimpleDelegator
      def ok?
        case response
        when String then response == "OK"
        when Integer then response >= 1
        when Array then array_ok?
        else response
        end
      end

      def nil?
        response.nil?
      end

      private

      def array_ok?
        response.all? do |pipeline_response|
          Response.new(pipeline_response).ok?
        end
      end

      def response
        __getobj__
      end
    end
  end
end
