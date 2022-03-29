# frozen_string_literal: true

class AddColumnAppIdToTokens < ActiveRecord::Migration[6.0]
  def change
    add_reference :tokens, :my_app, type: :uuid, foreign_key: true
  end
end
