# frozen_string_literal: true
class AddUniqueIndexToLists < ActiveRecord::Migration[6.0]
  def change
      add_index :lists, [:domain, :key], unique: true
  end
end
