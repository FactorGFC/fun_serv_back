# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::TermsController, term: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /terms' do
    before :each do
      FactoryBot.create_list(:term, 10)
      get '/api/v1/terms', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de plazos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Term.count)
    end
  end

  describe 'GET /terms/:id' do
    before :each do
      @term = FactoryBot.create(:term)
      get "/api/v1/terms/#{@term.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el plazo solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @term.id
    end
    it 'manda los atributos del plazo' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'key', 'description', 'value', 'term_type', 'credit_limit', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /terms' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/terms', params: { token: @token.token, secret_key: @my_app.secret_key, term:
                                                    { key: '12 Meses', description: '12 meses', value: 12, term_type: 'ME', credit_limit: '100000.00' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo plazo' do
        expect do
          post '/api/v1/terms', params: { token: @token.token, secret_key: @my_app.secret_key, term:
            { key: '12 Meses', description: '12 meses', value: 12, term_type: 'ME', credit_limit: '100000.00' } }
        end.to change(Term, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('12 Meses')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/terms', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/terms', params: { token: @token.token, secret_key: @my_app.secret_key, term:
          { key: '12 Meses', description: '12 meses', value: 12, term_type: 'ME', credit_limit: '100000.00' } }
      end
    end
  end

  describe 'PATCH /terms/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        patch api_v1_term_path(@term), params: { token: @token.token, secret_key: @my_app.secret_key, term: { key: '36 Meses' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza el plazo indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('36 Meses')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @term = FactoryBot.create(:term)
        patch api_v1_term_path(@term), params: { token: @token.token, secret_key: my_app.secret_key,
                                                 term: { key: '36 Meses' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /plazos' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
      end
      it {
        delete api_v1_term_path(@term), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina el plazo indicado' do
        expect do
          delete api_v1_term_path(@term), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Term, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        delete api_v1_term_path(@term),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
