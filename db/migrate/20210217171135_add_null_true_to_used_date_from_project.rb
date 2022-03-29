class AddNullTrueToUsedDateFromProject < ActiveRecord::Migration[6.0]
  def change
    change_column :projects, :used_date, :date, null: true
  end
end
