# frozen_string_literal: true

# == Schema Information
#
# Table name: my_apps
#
#  id                 :uuid             not null, primary key
#  javascript_origins :string
#  secret_key         :string
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  app_id             :string
#  user_id            :uuid             not null
#
# Indexes
#
#  index_my_apps_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

RSpec.describe MyApp, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:user) }

  it 'debería generar un app_id antes de crear el registro' do
    my_app = FactoryBot.create(:my_app)
    expect(my_app.app_id).to_not be_nil
  end

  it 'debería generar un secret_key antes de crear el registro' do
    my_app = FactoryBot.create(:my_app)
    expect(my_app.secret_key).to_not be_nil
  end

  it 'debería poder encontrar sus propios tokens' do
    my_app = FactoryBot.create(:my_app)
    token = FactoryBot.create(:token, my_app: my_app, user: my_app.user)

    expect(my_app.is_your_token?(token)).to eq(true)
  end

  it 'debería debería retornar falso para is_your_token si el token no es de esta aplicación' do
    my_app = FactoryBot.create(:my_app)
    second_app = FactoryBot.create(:my_app, user: my_app.user)
    token = FactoryBot.create(:token, my_app: second_app, user: my_app.user)

    expect(my_app.is_your_token?(token)).to eq(false)
  end
end
