# frozen_string_literal: true

require "redi_search/index"

module RediSearch
  module Model
    def redi_search(**options)
      index = Index.new(options[:index_name] || "#{name.underscore}_idx",
                        options[:schema])

      class_eval do
        cattr_reader :redi_search_index

        class_variable_set :@@redi_search_index, index
      end

      class << self
        def search(query)
          class_variable_get(:@@redi_search_index).search(query)
        end

        def reindex
          index = class_variable_get(:@@redi_search_index)

          index.create unless index.exist?
          find_each do |record|
            index.add(record)
          end
        end
      end
    end
  end
end
