class CreateUserOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_options, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :option, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
