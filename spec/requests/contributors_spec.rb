# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ContributorsController, contributor_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /contributors' do
    before :each do
      FactoryBot.create_list(:contributor, 10)
      get '/api/v1/contributors', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de contribuyentes' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Contributor.count)
    end
  end

  describe 'GET /contributors/:id' do
    before :each do
      @contributor = FactoryBot.create(:contributor)
      get "/api/v1/contributors/#{@contributor.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el contribuyente solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @contributor.id
    end

    it 'manda los atributos del contribuyente' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'contributor_type', 'bank', 'account_number',
                                                                 'clabe', 'person_id', 'legal_entity_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /contributors' do
    context 'con token válido persona moral' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        @legal_entity2 = FactoryBot.create(:legal_entity)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { contributor_type: 'Persona moral', bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 1_234_567_891_234_567, legal_entity_id: @legal_entity.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo contribuyente' do
        expect do
          post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                 contributor: { contributor_type: 'Persona moral', bank: 'Bancomer',
                                                                account_number: 123_456_789, clabe: 1_234_567_891_234_567, legal_entity_id: @legal_entity2.id } }
        end.to change(Contributor, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['contributor_type']).to eq('Persona moral')
      end
    end

    context 'con token válido persona física' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @person = FactoryBot.create(:person)
        @person2 = FactoryBot.create(:person)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { contributor_type: 'PERSONA FÍSICA', bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 123_456_789_123_456_789, person_id: @person.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo contribuyente' do
        expect do
          post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                 contributor: { contributor_type: 'PERSONA FÍSICA',
                                                                bank: 'Bancomer', account_number: 123_456_789, clabe: 123_456_789_123_456_789, person_id: @person2.id } }
        end.to change(Contributor, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['contributor_type']).to eq('PERSONA FÍSICA')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/contributors', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { contributor_type: 'Persona moral', bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 123_456_789_123_456_789, legal_entity_id: @legal_entity.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el contribuyente' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 123_456_789_123_456_789, legal_entity_id: @legal_entity.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el contribuyente' do
        json = JSON.parse(response.body)
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end

    context 'con persona física inválida' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @person = FactoryBot.create(:person)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { contributor_type: 'Persona moral', bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 123_456_789_123_456_789, person_id: 99 } }
      end
      it { expect(response).to have_http_status(404) }

      it 'responde con los errores al guardar el contribuyente' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

    context 'con persona moral inválida' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        post '/api/v1/contributors', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               contributor: { contributor_type: 'Persona moral', bank: 'Bancomer',
                                                              account_number: 123_456_789, clabe: 123_456_789_123_456_789, legal_entity_id: 99 } }
      end
      it { expect(response).to have_http_status(404) }

      it 'responde con los errores al guardar el contribuyente' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end

  describe 'PATCH /contributors/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor = FactoryBot.create(:contributor)
        patch api_v1_contributor_path(@contributor), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                               contributor: { contributor_type: 'Persona física modificada' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el contribuyente indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['contributor_type']).to eq('Persona física modificada')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @contributor = FactoryBot.create(:contributor)
        patch api_v1_contributor_path(@contributor), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               contributor: { contributor_type: 'Persona física modificada' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /contributors' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor = FactoryBot.create(:contributor)
      end
      it {
        delete api_v1_contributor_path(@contributor), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el contribuyente indicado' do
        expect do
          delete api_v1_contributor_path(@contributor), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Contributor, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor = FactoryBot.create(:contributor)
        delete api_v1_contributor_path(@contributor),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
