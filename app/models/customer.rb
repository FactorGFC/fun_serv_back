# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id                  :uuid             not null, primary key
#  assist_bonus        :decimal(15, 4)
#  attached            :string
#  child_support       :decimal(15, 4)
#  christmas_bonus     :decimal(15, 4)
#  credit_cp           :decimal(15, 4)
#  credit_lp           :decimal(15, 4)
#  customer_type       :string           not null
#  extra1              :string
#  extra2              :string
#  extra3              :string
#  extra_expenses      :decimal(15, 4)
#  family_expenses     :decimal(15, 4)
#  food_vouchers       :decimal(15, 4)
#  house_rent          :decimal(15, 4)
#  immediate_superior  :string
#  imms                :decimal(15, 4)
#  infonavit           :decimal(15, 4)
#  insurance_discount  :decimal(15, 4)
#  job                 :string
#  name                :string           not null
#  net_expenses        :decimal(15, 4)
#  ontime_bonus        :decimal(15, 4)
#  other_income        :decimal(15, 4)
#  salary              :decimal(15, 4)   not null
#  salary_period       :string           not null
#  savings_bank        :decimal(15, 4)
#  savings_found       :decimal(15, 4)
#  savings_found_loand :decimal(15, 4)
#  seniority           :decimal(15, 4)
#  status              :string           not null
#  taxes               :decimal(15, 4)
#  total_income        :decimal(15, 4)
#  total_savings_found :decimal(15, 4)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :uuid
#  contributor_id      :uuid             not null
#  file_type_id        :uuid
#  user_id             :uuid
#
# Indexes
#
#  index_customers_on_company_id      (company_id)
#  index_customers_on_contributor_id  (contributor_id)
#  index_customers_on_file_type_id    (file_type_id)
#  index_customers_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
class Customer < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerSchema  
  belongs_to :contributor
  belongs_to :user, optional: true
  belongs_to :file_type, optional: true
  belongs_to :company
  has_many :customer_credits
  has_many :customer_personal_references
  has_many :people, through: :contributors
  has_many :legal_entities, through: :contributors
  has_many :credit_bureaus
  has_many :listado_alsupers

  validates :customer_type, presence: true
  validates :name, presence: true
  validates :status, presence: true
  validates :salary, presence: true
  validates :salary_period, presence: true

  def self.get_customer_company_address(id)
    @query = "SELECT  coa.suburb colonia,coa.street calle, coa.external_number numero_exterior,
    coa.postal_code codigo_postal, mun.name municipio, sta.name estado
    FROM customer_credits cuc
      JOIN customers cus ON (cus.id = cuc.customer_id)
      JOIN contributors con ON (cus.contributor_id = con.id)
      JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
      JOIN states sta ON (sta.id = coa.state_id)
      JOIN municipalities mun ON (mun.id = coa.municipality_id)
              WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', id.to_s
    begin
      result = self.connection.exec_query(@query, :skip_logging)
      self.connection.close
    rescue => e
      Debug.exception e, 'exec_q'
      self.connection.close
      result = nil
    end
    return result

  end

  def self.get_customer_data(id)

    @query = "SELECT us.job puesto,cus.credit_lp creditos_lp,cus.credit_cp creditos_personales,cus.seniority antiguedad,cus.house_rent renta,cus.immediate_superior jefe_inmediato,cus.other_income otros_ingresos,cus.total_income ingreso_total,cus.salary_period frecuencia_de_pago,cus.net_expenses total_gastos,cus.salary salario,cus.id id_cliente, cus.name nombre_cliente, cus.customer_type tipo_cliente, cus.status status_cliente, cus.user_id id_usuario, cus.file_type_id id_tipo_expediente, con.id id_contribuyente, 
    con.contributor_type tipo_contribuyente, con.bank banco, con.account_number cuenta_bancaria, con.clabe cuenta_clabe, con.person_id id_persona_fisica, con.legal_entity_id id_persona_moral, peo.fiscal_regime pf_regimen_fiscal, 
    peo.rfc pf_rfc, peo.curp pf_curp, peo.imss pf_numero_seguro_social, peo.first_name nombre, peo.last_name apellido_paterno, peo.second_last_name apellido_materno, peo.gender pf_genero, 
    peo.nationality pf_nacionalidad, peo.birthplace pf_lugar_nacimiento, peo.birthdate pf_fecha_nacimiento, peo.martial_status pf_estado_civil,peo.martial_regime pf_regimen_marital,peo.senior_dependents dependientes_mayores,peo.minior_dependents dependientes_menores,peo.housing_type tipo_vivienda, peo.id_type pf_tipo_identificacion, peo.identification pf_numero_identificacion, 
    peo.phone pf_telefono, peo.mobile pf_celular, peo.email pf_correo, peo.fiel pf_fiel, coa.street calle, coa.suburb colonia, coa.external_number numero_exterior,coa.apartment_number numero_apartamento, coa.postal_code codigo_postal,
    sta.name estado, mun.name municipio, cou.name pais,com.business_name nombre_empresa , com.start_date fecha_inicio_labores, com.sector giro_empresa,com.contributor_id company_contributor_id
    FROM customers cus
    JOIN users us ON (us.id = cus.user_id)
    JOIN companies com ON (cus.company_id = com.id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    JOIN people peo ON (peo.id = con.person_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
            WHERE cus.id = ':customer_id';"
    @query = @query.gsub ':customer_id', id.to_s
    begin
      result = self.connection.exec_query(@query, :skip_logging)
      self.connection.close
    rescue => e
      Debug.exception e, 'exec_q'
      self.connection.close
      result = nil
    end
    return result

  end

end
