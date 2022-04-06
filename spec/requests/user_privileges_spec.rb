# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::UserPrivilegesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @user = FactoryBot.create(:user_with_privileges)
  end

  describe 'GET /users/:user_id/user_privileges' do
    before :each do
      get "/api/v1/users/#{@user.id}/user_privileges", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de privilegios del usuario' do
      json = JSON.parse(response.body)
      expect(json.length).to eq(@user.user_privileges.count)
    end

    it 'manda los datos del privilegio' do
      json_array = JSON.parse(response.body)
      @user_privilege = json_array['data'][0]
      expect(@user_privilege['attributes'].keys).to contain_exactly('id', 'description', 'key', 'value', 'documentation', 'created_at', 'updated_at', 'user_id')
    end
  end

  describe 'GET /users/:user_id/user_privileges/:id' do
    before :each do
      @user_privilege = @user.user_privileges[0]

      get api_v1_user_user_privilege_path(@user, @user_privilege),
          params: { user_privilege: { description: 'Privilegio para editar', value: 'SI' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el privilegio solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['description']).to eq(@user_privilege.description)
      expect(json['data']['attributes']['id']).to eq(@user_privilege.id)
    end
  end

  describe 'POST /users/:user_id/user_privileges' do
    context 'con usuario válido' do
      before :each do
        post api_v1_user_user_privileges_path(@user),
             params: { user_privilege: { description: 'Privilegio para editar', key: 'PASS_USR_UPDATE', value: 'SI' },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de privilegios +1' do
        expect do
          post api_v1_user_user_privileges_path(@user),
               params: { user_privilege: { description: 'Privilegio para borrar', key: 'PASS_USR_UPDATE', value: 'SI' },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(UserPrivilege, :count).by(1)
      end
      it 'responde con el privilegio creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Privilegio para editar')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_user_user_privileges_path(@user),
             params: { user_privilege: { description: 'Privilegio para editar', value: 'SI' },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de privilegios +0' do
        expect do
          post api_v1_user_user_privileges_path(@user),
               params: { user_privilege: { description: 'Privilegio para editar', value: 'SI' },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(UserPrivilege, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /user/:user_id/user_privileges/:id' do
    before :each do
      @user_privilege = @user.user_privileges[0]
      patch api_v1_user_user_privilege_path(@user, @user_privilege),
            params: { user_privilege: { description: 'Privilegio para ver', value: 'SI' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['description']).to eq('Privilegio para ver')
    end
  end

  describe 'DELETE /users/:user_id/user_privileges/:id' do
    before :each do
      @user_privilege = @user.user_privileges[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_user_user_privilege_path(@user, @user_privilege),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el privilegio' do
      delete api_v1_user_user_privilege_path(@user, @user_privilege),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(UserPrivilege.where(id: @user_privilege.id)).to be_empty
    end

    it 'reduce el conteo de privilegios en -1' do
      expect do
        delete api_v1_user_user_privilege_path(@user, @user_privilege),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(UserPrivilege, :count).by(-1)
    end
  end
end
