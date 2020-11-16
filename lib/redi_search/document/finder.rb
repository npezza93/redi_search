# frozen_string_literal: true

module RediSearch
  class Document
    class Finder
      def initialize(index, document_id)
        @index = index
        @document_id = document_id
      end

      def find
        Document.new(index, document_id, Hash[*response]) if response?
      end

      private

      attr_reader :index, :document_id

      def response
        @response ||= call!("HGETALL", prepended_document_id)
      end

      def call!(*command)
        RediSearch.client.call!(*command, skip_ft: true)
      end

      def prepended_document_id
        if document_id.to_s.start_with? index.name
          document_id
        else
          "#{index.name}#{document_id}"
        end
      end

      def response?
        !response.to_a.empty?
      end
    end
  end
end
