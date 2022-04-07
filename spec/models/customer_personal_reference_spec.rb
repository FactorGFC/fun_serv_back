# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_personal_references
#
#  id               :uuid             not null, primary key
#  address          :string
#  first_name       :string           not null
#  last_name        :string           not null
#  phone            :string
#  reference_type   :string
#  second_last_name :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  customer_id      :uuid             not null
#
# Indexes
#
#  index_customer_personal_references_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
require 'rails_helper'

RSpec.describe CustomerPersonalReference, type: :model do
   it { should validate_presence_of :first_name }
   it { should validate_presence_of :last_name }
   it { should validate_presence_of :second_last_name }
   it { should belong_to(:customer) }
end
