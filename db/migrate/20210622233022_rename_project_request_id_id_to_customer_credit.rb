class RenameProjectRequestIdIdToCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_credits, :project_request_id_id, :project_request_id
  end
end
