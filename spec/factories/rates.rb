# == Schema Information
#
# Table name: rates
#
#  id                :uuid             not null, primary key
#  description       :string           not null
#  extra1            :string
#  extra2            :string
#  extra3            :string
#  key               :string           not null
#  value             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  credit_rating_id  :uuid
#  payment_period_id :uuid             not null
#  term_id           :uuid             not null
#
# Indexes
#
#  index_rates_on_credit_rating_id   (credit_rating_id)
#  index_rates_on_payment_period_id  (payment_period_id)
#  index_rates_on_term_id            (term_id)
#
# Foreign Keys
#
#  fk_rails_...  (credit_rating_id => credit_ratings.id)
#  fk_rails_...  (payment_period_id => payment_periods.id)
#  fk_rails_...  (term_id => terms.id)
#
FactoryBot.define do
  factory :rate do
    key { "12MAAM" }
    description { "Plazo a 12 pagos mensuales para AA" }
    value { "12.5" }
    extra1 { "MyString" }
    extra2 { "MyString" }
    extra3 { "MyString" }
    association :term, factory: :term
    association :payment_period, factory: :payment_period
    association :credit_rating, factory: :credit_rating
  end
end
