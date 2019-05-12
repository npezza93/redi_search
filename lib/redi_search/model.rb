# frozen_string_literal: true

require "redi_search/index"
require "redi_search/document/converter"

require "active_support/concern"

module RediSearch
  module Model
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :redi_search_index

      def redi_search(**options) # rubocop:disable Metrics/MethodLength
        @redi_search_index = Index.new(
          options[:index_name] || "#{name.underscore}_idx",
          options[:schema],
          self
        )

        if respond_to? :after_commit
          after_commit :redi_search_add_document, on: [:create, :update]
        end
        if respond_to? :after_destroy_commit
          after_destroy_commit :redi_search_delete_document
        end

        class << self
          def search(term = nil, **term_options)
            redi_search_index.search(term, **term_options)
          end

          def reindex
            redi_search_index.reindex(all)
          end
        end
      end
    end

    def redi_search_document
      Document::Converter.new(self.class.redi_search_index, self).document
    end

    def redi_search_delete_document
      return unless self.class.redi_search_index.exist?

      self.class.redi_search_index.del(self, delete_document: true)
    end

    def redi_search_add_document
      return unless self.class.redi_search_index.exist?

      self.class.redi_search_index.add(self)
    end
  end
end
