# == Schema Information
#
# Table name: user_options
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  option_id  :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_user_options_on_option_id  (option_id)
#  index_user_options_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (option_id => options.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe UserOption, type: :model do
  it { should validate_presence_of :user }
  it { should validate_presence_of :option }

  describe 'self.custom_update_or_create' do
    it 'crea un nuevo registro con un nuevo usuario y opcion' do
      user = FactoryBot.create(:user)
      option = FactoryBot.create(:option)

      expect do
        UserOption.custom_update_or_create(user, option)
      end.to change(UserOption, :count).by(1)
    end
  end
end
