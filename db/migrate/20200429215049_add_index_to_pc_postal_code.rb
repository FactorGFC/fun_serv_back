class AddIndexToPcPostalCode < ActiveRecord::Migration[6.0]
  def change
    add_index :postal_codes, :pc
  end
end
