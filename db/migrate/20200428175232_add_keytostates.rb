class AddKeytostates < ActiveRecord::Migration[6.0]
  def change
    add_column :states, :state_key, :string, null: false
  end
end
