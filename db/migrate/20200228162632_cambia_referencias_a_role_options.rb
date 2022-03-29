# frozen_string_literal: true

class CambiaReferenciasARoleOptions < ActiveRecord::Migration[6.0]
  def change
    rename_column :role_options, :roles_id, :role_id
    rename_column :role_options, :options_id, :option_id
  end
end
