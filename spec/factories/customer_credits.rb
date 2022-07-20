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
#  credit_folio      :string
#  currency          :string
#  debt_time         :decimal(15, 4)
#  destination       :string
#  end_date          :date             not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  fixed_payment     :decimal(15, 4)   not null
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
#
# Indexes
#
#  index_customer_credits_on_credit_rating_id   (credit_rating_id)
#  index_customer_credits_on_customer_id        (customer_id)
#  index_customer_credits_on_payment_period_id  (payment_period_id)
#  index_customer_credits_on_term_id            (term_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#

#
# Indexes
#
#  index_customer_credits_on_customer_id         (customer_id)
#  index_customer_credits_on_project_id          (project_id)
#  index_customer_credits_on_project_request_id  (project_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (project_request_id => project_requests.id)
#
FactoryBot.define do
  factory :customer_credit do
    total_requested { "100000.00" }
    capital { "100000.00" }
    interests { "20000.00" }
    iva { "5000.00" }
    total_debt { "125000.00" }
    fixed_payment { "10000.00" }
    total_payments { "0.00" }
    balance { "125000.00" }
    status { "AC" }
    start_date { "2021-02-01" }
    end_date { "2022-02-01" }
    attached { "http://credit124587.pdf" }
    restructure_term { "1" }
    rate { "18.50" }
    destination {"Gastos familiares"}
    amount_allowed {""}
    time_allowed {""}
    debt_time {"1"}
    iva_percent {"16.00"}
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }

    association :customer, factory: :customer
    association :term, factory: :term
    association :payment_period, factory: :payment_period
    #association :credit_rating, factory: :credit_rating
  
  end
end
