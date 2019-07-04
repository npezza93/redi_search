# frozen_string_literal: true

module RediSearch
  class Document
    class Finder
      def initialize(index, *document_ids)
        @index = index
        @document_ids = Array.wrap(document_ids)
      end

      def find
        if multi?
          parse_multi_documents
        else
          parse_document(document_ids.first, response)
        end
      end

      private

      attr_reader :index, :document_ids

      def response
        @response ||= call!(get_command, index.name, *prepended_document_ids)
      end

      def call!(*command)
        RediSearch.client.call!(*command)
      end

      def get_command
        if multi?
          "MGET"
        else
          "GET"
        end
      end

      def multi?
        document_ids.size > 1
      end

      def prepended_document_ids
        document_ids.map do |document_id|
          prepend_document_id(document_id)
        end
      end

      def prepend_document_id(id)
        if id.to_s.start_with? index.name
          id
        else
          "#{index.name}#{id}"
        end
      end

      def parse_multi_documents
        document_ids.map.with_index do |document_id, index|
          parse_document(document_id, response[index])
        end.compact
      end

      def parse_document(document_id, document_response)
        return if document_response.blank?

        Document.new(index, document_id, Hash[*document_response])
      end
    end
  end
end
