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
          document_ids.map.with_index do |document_id, index|
            parse_document(document_id, response[index])
          end.compact
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
          if document_id.to_s.start_with? index.name
            document_id
          else
            "#{index.name}#{document_id}"
          end
        end
      end

      def parse_document(document_id, response)
        return if response.blank?

        Document.new(index, document_id, Hash[*response])
      end
    end
  end
end
