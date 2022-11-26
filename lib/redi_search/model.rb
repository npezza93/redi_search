# frozen_string_literal: true

module RediSearch
  module Model
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :search_index

      # rubocop:disable Metrics/MethodLength
      def redi_search(**options, &schema)
        @search_index = Index.new(
          [options[:index_prefix], model_name.plural, RediSearch.env].
            compact.join("_"),
          self, &schema
        )
        register_search_commit_hooks

        scope :search_import, -> { all } unless defined?(search_import)

        include InstanceMethods
        extend ModelClassMethods
      end
      # rubocop:enable Metrics/MethodLength

      private

      def register_search_commit_hooks
        after_save_commit(:add_to_index) if respond_to?(:after_save_commit)
        after_destroy_commit(:remove_from_index) if
          respond_to?(:after_destroy_commit)
      end
    end

    module ModelClassMethods
      def search(term = nil, **term_options)
        search_index.search(term, **term_options)
      end

      def aggregate(term = nil, **term_options)
        search_index.aggregate(term, **term_options)
      end

      def spellcheck(term, distance: 1)
        search_index.spellcheck(term, distance: distance)
      end

      def reindex(recreate: false, only: [], batch_size: 1000)
        search_import.find_in_batches(batch_size: batch_size).all? do |group|
          search_index.reindex(
            group.map { |record| record.search_document(only: only) },
            recreate: recreate
          )
        end
      end
    end

    module InstanceMethods
      def search_document(only: [])
        Document.for_object(self.class.search_index, self, only: only)
      end

      def remove_from_index
        self.class.search_index.del(search_document)
      end

      def add_to_index
        self.class.search_index.add(search_document)
      end
    end
  end
end
