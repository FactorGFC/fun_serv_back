# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::FileTypesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /file_types' do
    before :each do
      FactoryBot.create_list(:file_type, 10)
      get '/api/v1/file_types', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de tipo de expedientes' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(FileType.count)
    end
  end

  describe 'GET /file_types/:id' do
    before :each do
      @file_type = FactoryBot.create(:file_type)
      get "/api/v1/file_types/#{@file_type.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el tipo de expediente solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @file_type.id
    end
    it 'manda los atributos del tipo de expediente' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'name', 'description', 'customer_type', 'funder_type', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /file_types' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/file_types', params: { token: @token.token, secret_key: @my_app.secret_key, file_type:
                                                    { name: 'Expediente para inversionistas', description: 'Expediente requerido para los inversionistas', funder_type: 'EXT_INV' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo tipo de expediente' do
        expect do
          post '/api/v1/file_types', params: { token: @token.token, secret_key: @my_app.secret_key, file_type:
            { name: 'Expediente para inversionistas', description: 'Expediente requerido para los inversionistas', funder_type: 'EXT_INV' } }
        end.to change(FileType, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['funder_type']).to eq('EXT_INV')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/file_types', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/file_types', params: { token: @token.token, secret_key: @my_app.secret_key, file_type:
          { name: 'Expediente para inversionistas', description: 'Expediente requerido para los inversionistas', funder_type: 'EXT_INV' } }
      end
    end
  end

  describe 'PATCH /file_types/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @file_type = FactoryBot.create(:file_type)
        patch api_v1_file_type_path(@file_type), params: { token: @token.token, secret_key: @my_app.secret_key, file_type: { funder_type: 'EXP_INV' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza el tipo de expediente indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['funder_type']).to eq('EXP_INV')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @file_type = FactoryBot.create(:file_type)
        patch api_v1_file_type_path(@file_type), params: { token: @token.token, secret_key: my_app.secret_key,
                                                           file_type: { user: 'Factor GFC' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /tipo de expedientes' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @file_type = FactoryBot.create(:file_type)
      end
      it {
        delete api_v1_file_type_path(@file_type), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina el tipo de expediente indicado' do
        expect do
          delete api_v1_file_type_path(@file_type), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(FileType, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @file_type = FactoryBot.create(:file_type)
        delete api_v1_file_type_path(@file_type),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
