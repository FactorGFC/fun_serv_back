class AddFileTypeToCustomerAndFunder < ActiveRecord::Migration[6.0]
  def change
    add_reference :customers, :file_type, type: :uuid, foreign_key: { to_table: :file_types }
    add_reference :funders, :file_type, type: :uuid, foreign_key: { to_table: :file_types }
  end
end
