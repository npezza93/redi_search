# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[6.0]
  def change
    create_table :characters do |t|
      t.string :first
      t.string :last
    end
  end
end
