class AddPersonAndLegalEntityToContributors < ActiveRecord::Migration[6.0]
  def change
    add_reference :contributors, :person, type: :uuid, foreign_key: { to_table: :people }
    add_reference :contributors, :legal_entity, type: :uuid, foreign_key: { to_table: :legal_entities }
  end
end
