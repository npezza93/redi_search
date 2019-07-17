# frozen_string_literal: true

require "redi_search/validatable"

module RediSearch
  class Add
    include Validatable

    validates_numericality_of :score, within: 0.0..1.0

    def initialize(index, document, score: 1.0, replace: {}, language: nil,
                   no_save: false)
      @index = index
      @document = document
      @score = score || 1.0
      @replace = replace
      @language = language
      @no_save = no_save
    end

    def call!
      validate!

      RediSearch.client.call!(*command).ok?
    end

    def call
      call!
    rescue Redis::CommandError
      false
    end

    private

    attr_reader :index, :document, :score, :replace, :language, :no_save

    def command
      ["ADD", index.name, document.document_id, score, *extract_options,
       "FIELDS", document.redis_attributes].compact
    end

    def extract_options
      opts = []
      opts << ["LANGUAGE", language] if language
      opts << "NOSAVE" if no_save
      opts << replace_options if replace?
      opts
    end

    def replace?
      replace.present?
    end

    def replace_options
      ["REPLACE"].tap do |replace_option|
        if replace.is_a?(Hash)
          replace_option << "PARTIAL" if replace[:partial]
          # replace_option << "NOCREATE" if replace[:no_create]
        end
      end
    end
  end
end
