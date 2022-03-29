# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::RolesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /roles' do
    before :each do
      FactoryBot.create_list(:role, 10)
      get '/api/v1/roles', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de roles' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Role.count)
    end
  end

  describe 'GET /roles/:id' do
    before :each do
      @role = FactoryBot.create(:role)
      get "/api/v1/roles/#{@role.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el rol solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @role.id
    end

    it 'manda los atributos del role' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'name', 'description', 'created_at', 'updated_at')
    end
  end

  describe 'POST /roles' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/roles', params: { token: @token.token, secret_key: @my_app.secret_key, role: { name: 'Administrador', description: 'Acceso a todos los módulos' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo rol' do
        expect do
          post '/api/v1/roles', params: { token: @token.token, secret_key: @my_app.secret_key, role: { name: 'Administrador', description: 'Acceso a todos los módulos' } }
        end.to change(Role, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Administrador')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/roles', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/roles', params: { token: @token.token, role: { name: 'Proveedor', description: 'Modulos del proveedor' }, secret_key: @my_app.secret_key }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/roles', params: { token: @token.token, role: { name: 'Administrador' }, secret_key: @my_app.secret_key }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el rol' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /roles/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @role = FactoryBot.create(:role)
        patch api_v1_role_path(@role), params: { token: @token.token, secret_key: @my_app.secret_key, role: { description: 'Acceso a módulos de proveedor y cadenas' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el rol indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Acceso a módulos de proveedor y cadenas')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @role = FactoryBot.create(:role)
        patch api_v1_role_path(@role), params: { token: @token.token, secret_key: my_app.secret_key,
                                                 role: { name: 'Administrador2' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /roles' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @role = FactoryBot.create(:role)
      end
      it {
        delete api_v1_role_path(@role), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el rol indicado' do
        expect do
          delete api_v1_role_path(@role), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Role, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @role = FactoryBot.create(:role)
        delete api_v1_role_path(@role),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
