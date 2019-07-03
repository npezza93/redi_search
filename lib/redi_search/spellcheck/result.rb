# frozen_string_literal: true

module RediSearch
  class Spellcheck
    Suggestion = Struct.new(:score, :suggestion)

    class Result
      attr_reader :term, :suggestions

      def initialize(term, suggestions)
        @term = term
        @suggestions = suggestions.map do |suggestion|
          Suggestion.new(suggestion[0].to_f, suggestion[1])
        end
      end

      #:nocov:
      def inspect
        inspection = %w(term suggestions).map do |field_name|
          "#{field_name}: #{public_send(field_name)}"
        end.compact.join(", ")

        "#<#{self.class} #{inspection}>"
      end

      def pretty_print(printer) # rubocop:disable Metrics/MethodLength
        printer.object_address_group(self) do
          printer.seplist(
            %w(term suggestions), proc { printer.text "," }
          ) do |field_name|
            printer.breakable " "
            printer.group(1) do
              printer.text field_name
              printer.text ":"
              printer.breakable
              printer.pp public_send(field_name)
            end
          end
        end
      end
      #:nocov:
    end
  end
end
