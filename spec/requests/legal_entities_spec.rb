# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::LegalEntitiesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /legal_entities' do
    before :each do
      FactoryBot.create_list(:legal_entity, 10)
      get '/api/v1/legal_entities', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de personas morales' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(LegalEntity.count)
    end
  end

  describe 'GET /legal_entities/:id' do
    before :each do
      @legal_entity = FactoryBot.create(:legal_entity)
      get "/api/v1/legal_entities/#{@legal_entity.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la persona moral solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @legal_entity.id
    end

    it 'manda los atributos de la persona moral' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'fiscal_regime', 'rfc', 'rug', 'business_name', 'phone', 'mobile', 'email',
                                                                 'business_email', 'main_activity', 'fiel', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /legal_entities' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/legal_entities', params: { token: @token.token, secret_key: @my_app.secret_key, legal_entity: {
          fiscal_regime: 'Persona moral', rfc: 'AAAA999999AAA', rug: '9995999AAAEEA', business_name: 'Google',
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', business_email: 'bmail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea una nueva persona moral' do
        expect do
          post '/api/v1/legal_entities', params: { token: @token.token, secret_key: @my_app.secret_key, legal_entity: {
            fiscal_regime: 'Persona moral', rfc: 'AAAA999999AAB', rug: '9995999AAAEEA', business_name: 'Google',
            phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', business_email: 'bmail@mail.com', fiel: false, extra1: 'valor1',
            extra2: 'valor2', extra3: 'valor3'
          } }
        end.to change(LegalEntity, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['rfc']).to eq('AAAA999999AAA')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/legal_entities', params: { secret_key: my_app.secret_key, legal_entity: {
          fiscal_regime: 'Persona moral', rfc: 'AAAA999999AAA', rug: '9995999AAAEEA', business_name: 'Google',
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', business_email: 'bmail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/legal_entities', params: { token: @token.token, secret_key: @my_app.secret_key, legal_entity: {
          fiscal_regime: 'Persona moral', rfc: 'AAAA999999AAA', rug: '9995999AAAEEA', business_name: 'Google',
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', business_email: 'bmail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/legal_entities', params: { token: @token.token, secret_key: @my_app.secret_key, legal_entity: {
          fiscal_regime: 'Persona moral'
        } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar la persona moral' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /legal_entities/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        patch api_v1_legal_entity_path(@legal_entity), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                                 legal_entity: { business_name: 'Amazon' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza la persona moral indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['business_name']).to eq('Amazon')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @legal_entity = FactoryBot.create(:legal_entity)
        patch api_v1_legal_entity_path(@legal_entity), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                 legal_entity: { business_name: 'Amazon' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /legal_entities' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
      end
      it {
        delete api_v1_legal_entity_path(@legal_entity), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina la persona moral indicada' do
        expect do
          delete api_v1_legal_entity_path(@legal_entity), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(LegalEntity, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity)
        delete api_v1_legal_entity_path(@legal_entity),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
