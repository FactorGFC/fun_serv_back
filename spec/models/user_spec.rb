# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :uuid             not null, primary key
#  email                :string           default(""), not null
#  gender               :string
#  job                  :string
#  name                 :string           default(""), not null
#  password_digest      :string           default(""), not null
#  reset_password_token :string
#  status               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  company_id           :uuid
#  role_id              :uuid
#
# Indexes
#
#  index_users_on_company_id  (company_id)
#  index_users_on_role_id     (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (role_id => roles.id)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should_not allow_value('eloy@gmail').for(:email) }
  it { should allow_value('eloy@gmail.com').for(:email) }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:email) }

  it 'deberia encontrar un usuario si el correo y la contraseña existe' do
    user = FactoryBot.create(:user)
    expect do
      auth = { email: user.email, password: user.password }
      User.from_omniauth(auth)
    end.to change(User, :count).by(0)
  end

  it 'deberia retornar el usuario si el correo y la contraseña existe' do
    user = FactoryBot.create(:user)
    expect do
      auth = { email: user.email, password: user.password }
      @user = User.from_omniauth(auth)
      @user.email eq(user.email)
    end
  end
end
