# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ListsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /lists' do
    before :each do
      FactoryBot.create_list(:list, 10)
      get '/api/v1/lists', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de listas' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(List.count)
    end
  end

  describe 'GET /lists/domain/:domain' do
    before :each do
      @domain = 'usuario_tipo'
      FactoryBot.create(:list, domain: @domain)
      FactoryBot.create(:list, domain: @domain)
      FactoryBot.create(:list, domain: @domain)
      get api_v1_lists_domain_filter_path(@domain), params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'cuenta las listas con el mismo dominio' do
      get api_v1_lists_domain_filter_path(@domain), params: { token: token.token, secret_key: my_app.secret_key }
      expect(List.where(domain: @domain).count).to eq(List.count)
    end
  end

  describe 'GET /lists/:id' do
    before :each do
      @list = FactoryBot.create(:list)
      get "/api/v1/lists/#{@list.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la lista solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @list.id
    end

    it 'manda los atributos de la lista' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'domain', 'key', 'value', 'description', 'created_at', 'updated_at')
    end
  end

  describe 'POST /lists' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/lists', params: { token: @token.token, secret_key: @my_app.secret_key, list: {
          domain: 'usuario.estatus', key: 'AC', value: 'Activo',
          description: 'Estatus activo para usuario'
        } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea una nueva lista' do
        expect do
          post '/api/v1/lists', params: { token: @token.token, secret_key: @my_app.secret_key, list: {
            domain: 'usuario.estatus', key: 'AC1', value: 'Activo',
            description: 'Estatus activo para usuario'
          } }
        end.to change(List, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['domain']).to eq('usuario.estatus')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/lists', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/lists', params: { token: @token.token, list: { domain: 'usuario.estatus', key: 'AC', value: 'Activo', description: 'Estatus activo para usuario' } }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/lists', params: { token: @token.token, list: { description: 'Estatus activo para usuario' }, secret_key: @my_app.secret_key }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar la lista' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /lists/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @list = FactoryBot.create(:list)
        patch api_v1_list_path(@list), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                 list: { description: 'Estatus activo para la tabla usuario' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza la lista indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Estatus activo para la tabla usuario')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @list = FactoryBot.create(:list)
        patch api_v1_list_path(@list), params: { token: @token.token, secret_key: my_app.secret_key,
                                                 list: { description: 'Estatus activo para la tabla usuario' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /lists' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @list = FactoryBot.create(:list)
      end
      it {
        delete api_v1_list_path(@list), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina la lista indicada' do
        expect do
          delete api_v1_list_path(@list), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(List, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @list = FactoryBot.create(:list)
        delete api_v1_list_path(@list),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
