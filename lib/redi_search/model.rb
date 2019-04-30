# frozen_string_literal: true

require "redi_search/index"
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

        class << self
          def search(query)
            redi_search_index.search(query)
          end

          def reindex
            redi_search_index.reindex(all)
          end
        end
      end
    end
  end
end
