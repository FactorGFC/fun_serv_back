# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::DocumentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /documents' do
    before :each do
      FactoryBot.create_list(:document, 10)
      get '/api/v1/documents', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de documentos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Document.count)
    end
  end

  describe 'GET /documents/:id' do
    before :each do
      @document = FactoryBot.create(:document)
      get "/api/v1/documents/#{@document.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el documento solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @document.id
    end
    it 'manda los atributos del documento' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'document_type', 'name', 'description', 'validation', 'ext_service_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /documents' do
    context 'con token válido sin servicio externo' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/documents', params: { token: @token.token, secret_key: @my_app.secret_key, document:
                                                    { document_type: 'Identificación', name: 'INE', description: 'Credencial del instituto nacional electoral',
                                                      validación: 'Rostro por OCR' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo documento' do
        expect do
          post '/api/v1/documents', params: { token: @token.token, secret_key: @my_app.secret_key, document:
                                                    { document_type: 'Identificación', name: 'INE', description: 'Credencial del instituto nacional electoral',
                                                      validación: 'Rostro por OCR' } }
        end.to change(Document, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['document_type']).to eq('Identificación')
      end
    end

    context 'con token válido con servicio externo' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_service = FactoryBot.create(:ext_service)
        post '/api/v1/documents', params: { token: @token.token, secret_key: @my_app.secret_key, document:
                                                    { document_type: 'Identificación', name: 'INE', description: 'Credencial del instituto nacional electoral',
                                                      validación: 'Rostro por OSR', ext_service_id: @ext_service.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo documento' do
        expect do
          post '/api/v1/documents', params: { token: @token.token, secret_key: @my_app.secret_key, document:
                                                    { document_type: 'Identificación', name: 'INE', description: 'Credencial del instituto nacional electoral',
                                                      validación: 'Rostro por OSR', ext_service_id: @ext_service.id } }
        end.to change(Document, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['document_type']).to eq('Identificación')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/documents', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/documents', params: { token: @token.token, secret_key: @my_app.secret_key, document:
                                                  { document_type: 'Identificación', name: 'INE', description: 'Credencial del instituto nacional electoral',
                                                    validación: 'Rostro por OSR' } }
      end
    end
  end

  describe 'PATCH /documents/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @document = FactoryBot.create(:document)
        patch api_v1_document_path(@document), params: { token: @token.token, secret_key: @my_app.secret_key, document: { document_type: 'Id' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza la documento indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['document_type']).to eq('Id')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @document = FactoryBot.create(:document)
        patch api_v1_document_path(@document), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               document: { document_type: 'Id' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /documentos' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @document = FactoryBot.create(:document)
      end
      it {
        delete api_v1_document_path(@document), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina el documento indicado' do
        expect do
          delete api_v1_document_path(@document), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Document, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @document = FactoryBot.create(:document)
        delete api_v1_document_path(@document),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
