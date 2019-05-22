# frozen_string_literal: true

class Character < ApplicationRecord
  redi_search(
    schema: { name: { text: { phonetic: "dm:en" } } },
    serializer: CharacterSerializer
  )
end
