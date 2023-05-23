class ChangeColumnsContributors < ActiveRecord::Migration[6.0]
  def change
    change_column :contributors, :account_number, :string
    change_column :contributors, :clabe, :string
  end
end
