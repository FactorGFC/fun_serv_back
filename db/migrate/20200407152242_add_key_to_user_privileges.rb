class AddKeyToUserPrivileges < ActiveRecord::Migration[6.0]
  def change
    add_column :user_privileges, :key, :string, null: false
  end
end
