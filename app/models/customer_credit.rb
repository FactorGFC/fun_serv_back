# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_credits
#
#  id                :uuid             not null, primary key
#  amount_allowed    :decimal(15, 4)
#  attached          :string
#  balance           :decimal(15, 4)   not null
#  capital           :decimal(15, 4)   not null
#  commission        :decimal(15, 4)
#  commission1       :decimal(15, 4)
#  credit_folio      :string
#  currency          :string
#  debt_time         :decimal(15, 4)
#  destination       :string
#  end_date          :date             not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  fixed_payment     :decimal(15, 4)   not null
#  insurance         :decimal(15, 4)
#  insurance1        :decimal(15, 4)
#  interests         :decimal(15, 4)   not null
#  iva               :decimal(15, 4)   not null
#  iva_percent       :decimal(15, 4)
#  rate              :decimal(, )      not null
#  restructure_term  :integer
#  start_date        :date             not null
#  status            :string           not null
#  time_allowed      :decimal(15, 4)
#  total_debt        :decimal(15, 4)   not null
#  total_payments    :decimal(15, 4)   not null
#  total_requested   :decimal(15, 4)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  credit_rating_id  :uuid
#  customer_id       :uuid             not null
#  payment_period_id :uuid
#  term_id           :uuid
#  user_id           :uuid
#
# Indexes
#
#  index_customer_credits_on_credit_rating_id   (credit_rating_id)
#  index_customer_credits_on_customer_id        (customer_id)
#  index_customer_credits_on_payment_period_id  (payment_period_id)
#  index_customer_credits_on_term_id            (term_id)
#  index_customer_credits_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#  fk_rails_...  (user_id => users.id)
#
class CustomerCredit < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerCreditSchema
  belongs_to :customer
  belongs_to :payment_period, optional: true
  belongs_to :term, optional: true
  belongs_to :user, optional: true
  #belongs_to :credit_rating
  
  has_many :sim_customer_payments, dependent: :destroy
  #has_many :current_customer_payments
  has_many :current_payments, -> { current_customer_payments }, class_name: 'SimCustomerPayment'
  has_many :pending_payments, -> { pending_customer_payments }, class_name: 'SimCustomerPayment'
  has_many :credit_analysis

  
  validates :start_date, presence: true
  validates :status, presence: true
  validates :total_requested, presence: true
  validates :capital, presence: true
  validates :interests, presence: true
  validates :iva, presence: true
  validates :total_debt, presence: true
  validates :total_payments, presence: true
  validates :balance, presence: true
  validates :fixed_payment, presence: true
  #validates :rate, presence: true
  
  before_create :calculate_balance_credit
  before_create :create_folio

  def calculate_balance_credit
  #  puts 'aqui calcula el balance!!!!!!!!!'
    self[:balance] = self[:total_debt] - self[:total_payments]
   # puts 'balanceeeee' + self[:balance].inspect
   # puts 'total_debt' + self[:total_debt].inspect
  end

  def create_folio
    t = Time.now
    folio = t.to_i
    self[:credit_folio] = "CN#{folio.to_s}"
  end

  def self.get_customer_credit_data(id)

    @query = "SELECT ter.value numero_pagos, ter.description plazo , 
    cus.credit_lp creditos_lp,cus.credit_cp creditos_personales,cus.seniority antiguedad,cus.house_rent renta,cus.immediate_superior jefe_inmediato,cus.other_income otros_ingresos,cus.total_income ingreso_total,cus.salary_period frecuencia_de_pago,cus.net_expenses total_gastos,cus.salary salario,cus.id id_cliente, cus.name nombre_cliente, cus.customer_type tipo_cliente, cus.status status_cliente, cus.user_id id_usuario, cus.file_type_id id_tipo_expediente, con.id id_contribuyente, 
    con.contributor_type tipo_contribuyente, con.bank banco, con.account_number cuenta_bancaria, con.clabe cuenta_clabe, con.person_id id_persona_fisica, con.legal_entity_id id_persona_moral, peo.fiscal_regime pf_regimen_fiscal, 
    peo.rfc pf_rfc, peo.curp pf_curp, peo.imss pf_numero_seguro_social, peo.first_name nombre, peo.last_name apellido_paterno, peo.second_last_name apellido_materno, peo.gender pf_genero, 
    peo.nationality pf_nacionalidad, peo.birthplace pf_lugar_nacimiento, peo.birthdate pf_fecha_nacimiento, peo.martial_status pf_estado_civil,peo.martial_regime pf_regimen_marital,peo.senior_dependents dependientes_mayores,peo.minior_dependents dependientes_menores,peo.housing_type tipo_vivienda, peo.id_type pf_tipo_identificacion, peo.identification pf_numero_identificacion, 
    peo.phone pf_telefono, peo.mobile pf_celular, peo.email pf_correo, peo.fiel pf_fiel, lee.fiscal_regime pm_regimen_fiscal, lee.rfc pm_rfc, lee.rug pm_rug, lee.business_name pm_nombre, lee.phone pm_telefono, lee.mobile pm_celular, 
    lee.email pm_correo, lee.business_email pm_correo_negocio, lee.main_activity pm_actividad_pricipal, lee.fiel pm_fiel, coa.street calle, coa.suburb colonia, coa.external_number numero_exterior,coa.apartment_number numero_apartamento, coa.postal_code codigo_postal,
    sta.name estado, mun.name municipio, cou.name pais,com.business_name nombre_empresa , com.start_date fecha_inicio_labores, com.sector giro_empresa,com.contributor_id company_contributor_id, cpr
    FROM customer_credits cuc
    JOIN customers cus ON (cus.id = cuc.customer_id)
    JOIN companies com ON (cus.company_id = com.id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    JOIN terms ter ON (ter.id = cuc.term_id)
    JOIN customer_personal_references cpr ON (cpr.customer_id = cus.id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    LEFT JOIN legal_entities lee ON (lee.id = con.legal_entity_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
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

end
