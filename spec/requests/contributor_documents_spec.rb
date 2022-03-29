# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::ContributorDocumentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor_file_type_document = FactoryBot.create(:contributor)
    @document = FactoryBot.create(:document)
    @file_type = FactoryBot.create(:file_type)
    @file_type_document = FactoryBot.create(:file_type_document, document: @document, file_type: @file_type)
    @contributor = FactoryBot.create(:contributor)    
    @contributor_document = FactoryBot.create(:contributor_document, file_type_document: @file_type_document, contributor: @contributor)
  end

  describe 'GET /contributors/:contributor_id/contributor_documents' do
    before :each do
      get "/api/v1/contributors/#{@contributor.id}/contributor_documents", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de documentos del contribuyente' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(ContributorDocument.count)
    end

    it 'manda los datos del documento' do
      json_array = JSON.parse(response.body)
      @contributor_document = json_array['data'][0]
      expect(@contributor_document['attributes'].keys).to contain_exactly('id', 'name', 'status', 'notes', 'url', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'contributor_id', 'file_type_document_id')
    end
  end

  describe 'GET /contributors/:contributor_id/contributor_documents/:id' do
    before :each do
      # @contributor_document = @contributor.contributor_documents[0]

      get api_v1_contributor_contributor_document_path(@contributor, @contributor_document),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el documento solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@contributor_document.id)
    end
  end

  describe 'POST /contributors/:contributor_id/contributor_documents' do
    context 'con usuario válido' do
      before :each do
        @document = FactoryBot.create(:document)
        @file_type = FactoryBot.create(:file_type)
        @file_type_document = FactoryBot.create(:file_type_document, document: @document, file_type: @file_type)
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_contributor_documents_path(@contributor),
             params: { contributor_document: { name: 'IFE', status: 'AL', notes: 'Credencial cargada', url: 'https://store/ife', file_type_document_id: @file_type_document.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de documentos +1' do
        expect do
          @document = FactoryBot.create(:document)
          @file_type = FactoryBot.create(:file_type)
          @file_type_document = FactoryBot.create(:file_type_document, document: @document, file_type: @file_type)
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_contributor_documents_path(@contributor),
          params: { contributor_document: { name: 'IFE', status: 'AL', notes: 'Credencial cargada', url: 'https://store/ife', file_type_document_id: @file_type_document.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(ContributorDocument, :count).by(1)
      end
      it 'respondel documento creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('IFE')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_contributor_contributor_documents_path(@contributor),
        params: { contributor_document: { name: 'IFE', status: 'AL', notes: 'Credencial cargada', url: 'https://store/ife', file_type_document_id: @file_type_document.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de documentos +0' do
        expect do
          post api_v1_contributor_contributor_documents_path(@contributor),
          params: { contributor_document: { name: 'IFE', status: 'AL', notes: 'Credencial cargada', url: 'https://store/ife', file_type_document_id: @file_type_document.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(ContributorDocument, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/contributor_documents/:id' do
    before :each do
      # @contributor_document = @contributor.contributor_documents[0]
      patch api_v1_contributor_contributor_document_path(@contributor, @contributor_document),
            params: { contributor_document: { name: 'Instituto federal electoral' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq('Instituto federal electoral')
    end
  end

  describe 'DELETE /contributors/:contributor_id/contributor_documents/:id' do
    before :each do
      # @contributor_document = @contributor.contributor_documents[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_contributor_contributor_document_path(@contributor, @contributor_document),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el documento' do
      delete api_v1_contributor_contributor_document_path(@contributor, @contributor_document),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(ContributorDocument.where(id: @contributor_document.id)).to be_empty
    end

    it 'reduce el conteo de documentos en -1' do
      expect do
        delete api_v1_contributor_contributor_document_path(@contributor, @contributor_document),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(ContributorDocument, :count).by(-1)
    end
  end
end
