# frozen_string_literal: true

class CreateSuperpowers < ActiveRecord::Migration[6.0]
  def change
    create_table :superpowers do |t|
      t.string :power
    end
  end
end
