# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ExtServicesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /ext_services' do
    before :each do
      FactoryBot.create_list(:ext_service, 10)
      get '/api/v1/ext_services', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de servicios externos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(ExtService.count)
    end
  end

  describe 'GET /ext_services/:id' do
    before :each do
      @ext_service = FactoryBot.create(:ext_service)
      get "/api/v1/ext_services/#{@ext_service.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el servicio externo solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @ext_service.id
    end
    it 'manda los atributos del servicio externo' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'supplier', 'user', 'api_key', 'token', 'url', 'rule', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /ext_services' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/ext_services', params: { token: @token.token, secret_key: @my_app.secret_key, ext_service:
                                                    { supplier: 'Tu identidad', user: 'Factor GFC', api_key: 'sfd446fgdfgd4345dfgd343',
                                                      token: 'sfd4dfgdfg54fd54345dfgd343', url: 'https://tuidentidad.com/api/Business/ine',
                                                      rule: 'se le manda una fotografía del INE y devuelve todos los datos' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo servicio externo' do
        expect do
          post '/api/v1/ext_services', params: { token: @token.token, secret_key: @my_app.secret_key, ext_service:
                                                      { supplier: 'Tu identidad', user: 'Factor GFC', api_key: 'sfd446fgdfgd4345dfgd343',
                                                        token: 'sfd4dfgdfg54fd54345dfgd343', url: 'https://tuidentidad.com/api/Business/ine',
                                                        rule: 'se le manda una fotografía del INE y devuelve todos los datos' } }
        end.to change(ExtService, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['user']).to eq('Factor GFC')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/ext_services', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/ext_services', params: { token: @token.token, secret_key: @my_app.secret_key, ext_service:
                                                    { supplier: 'Tu identidad', user: 'Factor GFC', api_key: 'sfd446fgdfgd4345dfgd343',
                                                      token: 'sfd4dfgdfg54fd54345dfgd343', url: 'https://tuidentidad.com/api/Business/ine',
                                                      rule: 'se le manda una fotografía del INE y devuelve todos los datos' } }
      end
    end
  end

  describe 'PATCH /ext_services/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_service = FactoryBot.create(:ext_service)
        patch api_v1_ext_service_path(@ext_service), params: { token: @token.token, secret_key: @my_app.secret_key, ext_service: { user: 'FactorGFC' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza la servicio externo indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['user']).to eq('FactorGFC')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @ext_service = FactoryBot.create(:ext_service)
        patch api_v1_ext_service_path(@ext_service), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               ext_service: { user: 'Factor GFC' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /servicios externos' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_service = FactoryBot.create(:ext_service)
      end
      it {
        delete api_v1_ext_service_path(@ext_service), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina el servicio externo indicado' do
        expect do
          delete api_v1_ext_service_path(@ext_service), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(ExtService, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_service = FactoryBot.create(:ext_service)
        delete api_v1_ext_service_path(@ext_service),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
