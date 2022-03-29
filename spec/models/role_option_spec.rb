# frozen_string_literal: true

# == Schema Information
#
# Table name: role_options
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  option_id  :uuid             not null
#  role_id    :uuid             not null
#
# Indexes
#
#  index_role_options_on_option_id  (option_id)
#  index_role_options_on_role_id    (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (option_id => options.id)
#  fk_rails_...  (role_id => roles.id)
#

require 'rails_helper'

RSpec.describe RoleOption, type: :model do
  it { should validate_presence_of :role }
  it { should validate_presence_of :option }

  describe 'self.custom_update_or_create' do
    it 'crea un nuevo registro con un nuevo rol y opcion' do
      role = FactoryBot.create(:role)
      option = FactoryBot.create(:option)

      expect do
        RoleOption.custom_update_or_create(role, option)
      end.to change(RoleOption, :count).by(1)
    end
  end
end
