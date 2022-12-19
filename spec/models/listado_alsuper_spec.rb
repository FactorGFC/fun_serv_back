# == Schema Information
#
# Table name: listado_alsupers
#
#  id               :uuid             not null, primary key
#  area             :string
#  banco            :string
#  categoria        :string
#  cla_area         :string
#  cla_depto        :string
#  cla_puesto       :string
#  cla_trab         :string
#  clabe            :string
#  curp             :string           default(""), not null
#  departamento     :string
#  extra1           :string
#  extra2           :string
#  extra3           :string
#  fecha_ingreso    :string
#  noafiliacion     :string           default(""), not null
#  nombre           :string           default(""), not null
#  primer_apellido  :string           default(""), not null
#  puesto           :string
#  rfc              :string           default(""), not null
#  segundo_apellido :string
#  tarjeta          :string
#  tipo_puesto      :string
#  categoria        :string
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
require 'rails_helper'

RSpec.describe ListadoAlsuper, type: :model do
  it { should validate_presence_of :noafiliacion }
  it { should validate_presence_of :customer_id }
  it { should belong_to(:customer) }
end
