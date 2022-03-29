# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::FileTypeDocumentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }

  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @file_type = FactoryBot.create(:file_type)
    @document = FactoryBot.create(:document)
    @file_type_document = FactoryBot.create(:file_type_document, file_type: @file_type, document: @document)
  end

  describe 'POST /file_type_documents' do
    before :each do
      post api_v1_file_type_documents_path,
           params: { file_type_id: @file_type.id, document_id: @document.id,
                     token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'responde con el nuevo documento para el tipo de expediente' do
      json = JSON.parse(response.body)
      # puts "\n\n #{json} \n\n"
      expect(json['data']['id']).to eq(FileTypeDocument.last.id)
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_file_type_documents_path,
             params: { file_type_id: @file_type.id, document_id: @document.id,
                       token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de documentos para el tipo de expediente' do
        expect do
          post api_v1_file_type_documents_path,
               params: { file_type_id: @file_type.id, document_id: @document.id,
                         token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
        end .to change(FileTypeDocument, :count).by(0)
      end
    end

    context 'con token vencido' do
      before :each do
        # new_user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: user, my_app: my_app)

        post api_v1_file_type_documents_path,
             params: { file_type_id: @file_type.id, document_id: @document.id,
                       token: @token.token, secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de documentos para el tipo de expediente' do
        expect do
          post api_v1_file_type_documents_path,
               params: { file_type_id: @file_type.id, document_id: @document.id,
                         token: @token.token, secret_key: my_app.secret_key }
        end .to change(FileTypeDocument, :count).by(0)
      end
    end

    context 'con app inválida' do
      before :each do
        post api_v1_file_type_documents_path,
             params: { file_type_id: @file_type.id, document_id: @document.id,
                       token: @token.token, secret_key: 'asdfggdf43543gsfs' }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de documentos para el tipo de expediente' do
        expect do
          post api_v1_file_type_documents_path,
               params: { file_type_id: @file_type.id, document_id: @document.id,
                         token: @token.token, secret_key: 'asdfggdf43543gsfs' }
        end .to change(FileTypeDocument, :count).by(0)
      end
    end
  end

  describe 'delete /file_type_documents' do
    before :each do
      @file_type_document2 = FactoryBot.create(:file_type_document)
      delete api_v1_file_type_document_path(@file_type_document),
             params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'elimina el documento para el tipo de expendiente' do
      expect do
        delete api_v1_file_type_document_path(@file_type_document2),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(FileTypeDocument, :count).by(-1)
    end
  end
end
