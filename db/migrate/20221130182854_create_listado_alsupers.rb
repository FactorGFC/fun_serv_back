class CreateListadoAlsupers < ActiveRecord::Migration[6.0]
  def change
    create_table :listado_alsupers, id: :uuid do |t|
      t.string :nombre, null: false, default: ''
      t.string :primer_apellido, null: false, default: ''
      t.string :segundo_apellido
      t.string :banco
      t.string :clabe
      t.string :cla_trab
      t.string :cla_depto
      t.string :departamento
      t.string :cla_area
      t.string :area
      t.string :cla_puesto
      t.string :puesto
      t.string :noafiliacion, null: false, default: '', foreign_key: true
      t.string :rfc, null: false, default: ''
      t.string :curp, null: false, default: ''
      t.string :tarjeta
      t.string :tipo_puesto
      t.string :fecha_ingreso
      t.references :customer, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
