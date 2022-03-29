class ChangeColumnsToPeople < ActiveRecord::Migration[6.0]
  def change
    change_column :people, :imss, :bigint
    change_column :people, :identification, :bigint
  end
end
