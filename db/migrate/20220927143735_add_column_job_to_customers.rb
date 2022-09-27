class AddColumnJobToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :job, :string
  end
end
