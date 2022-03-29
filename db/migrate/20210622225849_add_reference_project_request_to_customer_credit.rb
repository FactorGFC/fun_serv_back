class AddReferenceProjectRequestToCustomerCredit < ActiveRecord::Migration[6.0]
  def change
    add_reference :customer_credits, :project_request_id, type: :uuid, null: true, foreign_key: { to_table: :project_requests }
  end
end
