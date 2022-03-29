class AddRateToProjectRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :project_requests, :rate, :decimal, precision: 15, scale: 4, null: true
  end
end
