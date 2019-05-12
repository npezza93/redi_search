# frozen_string_literal: true

class User < ApplicationRecord
  redi_search schema: {
    first: { text: { phonetic: "dm:en" } },
    last: { text: { phonetic: "dm:en" } }
  }
end
