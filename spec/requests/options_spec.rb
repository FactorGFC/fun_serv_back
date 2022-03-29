# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::OptionsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /options' do
    before :each do
      FactoryBot.create_list(:option, 10)
      get '/api/v1/options', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de opciones' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Option.count)
    end
  end

  describe 'GET /options/:id' do
    before :each do
      @option = FactoryBot.create(:option)
      get "/api/v1/options/#{@option.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la opcion solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @option.id
    end
    it 'manda los atributos de la opcion' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'name', 'description', 'group', 'url', 'created_at', 'updated_at')
    end
  end

  describe 'POST /options' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/options', params: { token: @token.token, secret_key: @my_app.secret_key, option: { name: 'Opción1', description: 'Acceso a todos los módulos', expires_at: DateTime.now } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea una nueva opción' do
        expect do
          post '/api/v1/options', params: { token: @token.token, secret_key: @my_app.secret_key, option: { name: 'Opción1', description: 'Acceso a todos los módulos', expires_at: DateTime.now } }
        end.to change(Option, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Opción1')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/options', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/options', params: { token: @token.token, option: { name: 'Opcion1', description: 'Primera opción del menú' }, secret_key: @my_app.secret_key }
      end
    end
  end

  describe 'PATCH /options/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @option = FactoryBot.create(:option)
        patch api_v1_option_path(@option), params: { token: @token.token, secret_key: @my_app.secret_key, option: { description: 'Segunda opcion del menú' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza la opcion indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Segunda opcion del menú')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @option = FactoryBot.create(:option)
        patch api_v1_option_path(@option), params: { token: @token.token, secret_key: my_app.secret_key,
                                                     option: { name: 'Opción1' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /opciones' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @option = FactoryBot.create(:option)
      end
      it {
        delete api_v1_option_path(@option), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina la opción indicada' do
        expect do
          delete api_v1_option_path(@option), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Option, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @option = FactoryBot.create(:option)
        delete api_v1_option_path(@option),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
