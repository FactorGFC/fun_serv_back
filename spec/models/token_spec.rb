# frozen_string_literal: true

# == Schema Information
#
# Table name: tokens
#
#  id         :uuid             not null, primary key
#  expires_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  my_app_id  :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_tokens_on_my_app_id  (my_app_id)
#  index_tokens_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (my_app_id => my_apps.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe Token, type: :model do
  it { should belong_to(:my_app) }
  it 'should return valid when is not expired' do
    token = FactoryBot.create(:token, expires_at: DateTime.now + 1.minute, user: FactoryBot.create(:sequence_user))
    expect(token.is_valid?).to eq(true)
  end
  it 'should return invalid when is expired' do
    token = FactoryBot.create(:token, expires_at: DateTime.now - 1.day, user: FactoryBot.create(:sequence_user))
    expect(token.is_valid?).to eq(false)
  end
end
