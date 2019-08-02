# frozen_string_literal: true

module RediSearch
  class Document
    module Display
      def inspect
        inspection = pretty_print_attributes.map do |field_name|
          "#{field_name}: #{public_send(field_name)}"
        end.compact.join(", ")

        "#<#{self.class} #{inspection}>"
      end

      def pretty_print_attributes
        pp_attrs = attributes.keys.dup
        pp_attrs.push("document_id")
        pp_attrs.push("score") if score

        pp_attrs.compact
      end

      #:nocov:
      def pretty_print(printer) # rubocop:disable Metrics/MethodLength
        printer.object_address_group(self) do
          printer.seplist(
            pretty_print_attributes , proc { printer.text "," }
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
