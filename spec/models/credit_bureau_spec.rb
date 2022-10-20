# frozen_string_literal: true
# == Schema Information
#
# Table name: credit_bureaus
#
#  id            :bigint           not null, primary key
#  bureau_info   :jsonb
#  bureau_report :jsonb
#  extra1        :string
#  extra2        :string
#  extra3        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  bureau_id     :integer
#  customer_id   :uuid             not null
#
# Indexes
#
#  index_credit_bureaus_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
RSpec.describe CreditBureau, type: :model do
      it { should validate_presence_of :bureau_id }
      it { should validate_presence_of :customer_id }
      it { should belong_to(:customer) }

  end
