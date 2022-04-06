# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::RoleOptionsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }

  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @role = FactoryBot.create(:role)
    @option = FactoryBot.create(:option)
    @role_option = FactoryBot.create(:role_option, role: @role, option: @option)
  end

  describe 'POST /:role/role_options' do
    before :each do
      post api_v1_role_options_path,
           params: { role_id: @role.id, option_id: @option.id,
                     token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'responde con el nuevo role_options' do
      json = JSON.parse(response.body)
      # puts "\n\n #{json} \n\n"
      expect(json['data']['id']).to eq(RoleOption.last.id)
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_role_options_path,
             params: { role_id: @role.id, option_id: @option.id,
                       token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del rol' do
        expect do
          post api_v1_role_options_path,
               params: { role_id: @role.id, option_id: @option.id,
                         token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
        end.to change(RoleOption, :count).by(0)
      end
    end

    context 'con token vencido' do
      before :each do
        # new_user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: user, my_app: my_app)

        post api_v1_role_options_path,
             params: { role_id: @role.id, option_id: @option.id,
                       token: @token.token, secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del rol' do
        expect do
          post api_v1_role_options_path,
               params: { role_id: @role.id, option_id: @option.id,
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(RoleOption, :count).by(0)
      end
    end

    context 'con app inválida' do
      before :each do
        post api_v1_role_options_path,
             params: { role_id: @role.id, option_id: @option.id,
                       token: @token.token, secret_key: 'asdfggdf43543gsfs' }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de opciones del rol' do
        expect do
          post api_v1_role_options_path,
               params: { role_id: @role.id, option_id: @option.id,
                         token: @token.token, secret_key: 'asdfggdf43543gsfs' }
        end.to change(RoleOption, :count).by(0)
      end
    end
  end

  describe 'delete /role_options' do
    before :each do
      @role_option2 = FactoryBot.create(:role_option)
      delete api_v1_role_option_path(@role_option),
             params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'elimina la opción indicada' do
      expect do
        delete api_v1_role_option_path(@role_option2),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(RoleOption, :count).by(-1)
    end
  end
end
