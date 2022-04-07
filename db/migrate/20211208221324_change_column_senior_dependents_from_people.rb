# frozen_string_literal: true
class ChangeColumnSeniorDependentsFromPeople < ActiveRecord::Migration[6.0]
  def change
  rename_column :people, :senior_depentents, :senior_dependents
  end
end
