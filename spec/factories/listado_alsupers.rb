# == Schema Information
#
# Table name: listado_alsupers
#
#  id               :uuid             not null, primary key
#  area             :string
#  banco            :string
#  cla_area         :string
#  cla_depto        :string
#  cla_puesto       :string
#  cla_trab         :string
#  clabe            :string
#  curp             :string           default(""), not null
#  departamento     :string
#  fecha_ingreso    :string
#  noafiliacion     :string           default(""), not null
#  nombre           :string           default(""), not null
#  primer_apellido  :string           default(""), not null
#  puesto           :string
#  rfc              :string           default(""), not null
#  segundo_apellido :string
#  tarjeta          :string
#  tipo_puesto      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  customer_id      :uuid
#
# Indexes
#
#  index_listado_alsupers_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
FactoryBot.define do
  factory :listado_alsuper do
    nombre { "Pedro" }
    primer_apellido { "Paramo" }
    segundo_apellido { "Paramo" }
    banco { "Global" }
    clabe { "123456789987654321" }
    cla_trab { "123456" }
    cla_depto { "123456" }
    departamento { "Empleado" }
    cla_area { "123456" }
    area { "Trabajadores" }
    cla_puesto { "123456" }
    puesto { "Empleado" }
    noafiliacion { "123456" }
    rfc { "ABCD123456GH45IO5" }
    curp { "ABCD123456GH457" }
    tarjeta { "123456" }
    tipo_puesto { "Empleado 1" }
    fecha_ingreso {"29-Sep-88"}

    association :customer, factory: :customer
  end
end
