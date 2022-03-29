class AddStatusToFundingRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :funding_requests, :status, :string, null: false
  end
end
