class AddColumnsToListadoAlsupers < ActiveRecord::Migration[6.0]
  def change
        add_column :listado_alsupers, :categoria, :string
        add_column :listado_alsupers, :extra1, :string
        add_column :listado_alsupers, :extra2, :string
        add_column :listado_alsupers, :extra3, :string
  end
end
