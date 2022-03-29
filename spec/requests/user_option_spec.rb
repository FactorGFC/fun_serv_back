# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::UserOptionsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }

  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @user = FactoryBot.create(:user)
    @option = FactoryBot.create(:option)
    @user_option = FactoryBot.create(:user_option, user: @user, option: @option)
  end

  describe 'POST /user_options' do
    before :each do
      post api_v1_user_options_path,
           params: { user_id: @user.id, option_id: @option.id,
                     token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'responde con el nuevo user_options' do
      json = JSON.parse(response.body)
      # puts "\n\n #{json} \n\n"
      expect(json['data']['id']).to eq(UserOption.last.id)
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_user_options_path,
             params: { user_id: @user.id, option_id: @option.id,
                       token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del usuario' do
        expect do
          post api_v1_user_options_path,
               params: { user_id: @user.id, option_id: @option.id,
                         token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
        end .to change(UserOption, :count).by(0)
      end
    end

    context 'con token vencido' do
      before :each do
        # new_user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: user, my_app: my_app)

        post api_v1_user_options_path,
             params: { user_id: @user.id, option_id: @option.id,
                       token: @token.token, secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del usuario' do
        expect do
          post api_v1_user_options_path,
               params: { user_id: @user.id, option_id: @option.id,
                         token: @token.token, secret_key: my_app.secret_key }
        end .to change(UserOption, :count).by(0)
      end
    end

    context 'con app inválida' do
      before :each do
        post api_v1_user_options_path,
             params: { user_id: @user.id, option_id: @option.id,
                       token: @token.token, secret_key: 'asdfggdf43543gsfs' }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del usuario' do
        expect do
          post api_v1_user_options_path,
               params: { user_id: @user.id, option_id: @option.id,
                         token: @token.token, secret_key: 'asdfggdf43543gsfs' }
        end .to change(UserOption, :count).by(0)
      end
    end
  end

  describe 'delete /user_options' do
    before :each do
      @user_option2 = FactoryBot.create(:user_option)
      delete api_v1_user_option_path(@user_option),
             params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'elimina la opción indicada' do
      expect do
        delete api_v1_user_option_path(@user_option2),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(UserOption, :count).by(-1)
    end
  end
end
