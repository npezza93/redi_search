# frozen_string_literal: true

require "redi_search/index"

module RediSearch
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :redi_search_index, :redi_search_serializer

      # rubocop:disable Metrics/MethodLength
      def redi_search(**options, &schema)
        @redi_search_index = Index.new(
          [options[:index_prefix], model_name.plural, RediSearch.env].compact.join("_"),
          self, &schema
        )
        @redi_search_serializer = options[:serializer]
        register_redi_search_commit_hooks

        scope :search_import, -> { all }

        include InstanceMethods
        extend ModelClassMethods
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

    module ModelClassMethods
      def search(term = nil, **term_options)
        redi_search_index.search(term, **term_options)
      end

      def spellcheck(term, distance: 1)
        redi_search_index.spellcheck(term, distance: distance)
      end

      def reindex(recreate: false, only: [])
        search_import.find_in_batches.all? do |group|
          redi_search_index.reindex(
            group.map { |record| record.redi_search_document(only: only) },
            recreate: recreate
          )
        end
      end
    end

    module InstanceMethods
      def redi_search_document(only: [])
        Document.for_object(
          self.class.redi_search_index, self,
          only: only, serializer: self.class.redi_search_serializer
        )
      end

      def redi_search_delete_document
        self.class.redi_search_index.del(redi_search_document)
      end

      def redi_search_add_document
        self.class.redi_search_index.add(redi_search_document)
      end
    end
  end
end
