# frozen_string_literal: true

require "redi_search/index"
require "active_support/concern"

module RediSearch
  module Model
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :redi_search_index

      # rubocop:disable Metrics/MethodLength
      def redi_search(**options)
        @redi_search_index = Index.new(
          options[:index_name] || "#{name.underscore}_idx", options[:schema],
          self
        )
        register_redi_search_commit_hooks

        class << self
          def search(term = nil, **term_options)
            redi_search_index.search(term, **term_options)
          end

          def reindex
            redi_search_index.reindex(all.map(&:redi_search_document))
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def register_redi_search_commit_hooks
        after_commit(:redi_search_add_document, on: %i(create update)) if
          respond_to?(:after_commit)
        after_destroy_commit(:redi_search_delete_document) if
          respond_to?(:after_destroy_commit)
      end
    end

    def redi_search_document
      Document.for_object(self.class.redi_search_index, self)
    end

    def redi_search_delete_document
      return unless self.class.redi_search_index.exist?

      self.class.redi_search_index.del(
        redi_search_document, delete_document: true
      )
    end

    def redi_search_add_document
      return unless self.class.redi_search_index.exist?

      self.class.redi_search_index.add(redi_search_document)
    end
  end
end
