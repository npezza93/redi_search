# frozen_string_literal: true

require "redi_search/index"

module RediSearch
  module Model
    def redi_search(**options)
      index = Index.new(
        (options[:index_name] || name.underscore + "_idx").to_s,
        options[:schema]
      )

      class_eval do
        cattr_reader :redi_search_index

        class_variable_set :@@redi_search_index, index
      end
    end
  end
end
