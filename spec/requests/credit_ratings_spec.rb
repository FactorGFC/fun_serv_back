# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::CreditRatingsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /credit_ratings' do
    before :each do
      FactoryBot.create_list(:credit_rating, 10)
      get '/api/v1/credit_ratings', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de calificaciones' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(CreditRating.count)
    end
  end

  describe 'GET /credit_ratings/:id' do
    before :each do
      @credit_rating = FactoryBot.create(:credit_rating)
      get "/api/v1/credit_ratings/#{@credit_rating.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la calificación solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @credit_rating.id
    end
    it 'manda los atributos dla calificación' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'key', 'description', 'value', 'cr_type', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /credit_ratings' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/credit_ratings', params: { token: @token.token, secret_key: @my_app.secret_key, credit_rating:
                                                    { key: 'AA', description: 'Doble A', value: '0.50', cr_type: 'Tasa' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo tipo de expediente' do
        expect do
          post '/api/v1/credit_ratings', params: { token: @token.token, secret_key: @my_app.secret_key, credit_rating:
                                                { key: 'AA', description: 'Doble A', value: '0.50', cr_type: 'Tasa' } }
        end.to change(CreditRating, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('AA')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/credit_ratings', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/credit_ratings', params: { token: @token.token, secret_key: @my_app.secret_key, credit_rating:
                                                { key: 'AA', description: 'Doble A', value: '0.50', cr_type: 'Tasa' } }
      end
    end
  end

  describe 'PATCH /credit_ratings/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @credit_rating = FactoryBot.create(:credit_rating)
        patch api_v1_credit_rating_path(@credit_rating), params: { token: @token.token, secret_key: @my_app.secret_key, credit_rating: { description: 'Calificación doble AA' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza la calificación indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Calificación doble AA')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @credit_rating = FactoryBot.create(:credit_rating)
        patch api_v1_credit_rating_path(@credit_rating), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                   credit_rating: { key: 'AAA' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /calificaciones' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @credit_rating = FactoryBot.create(:credit_rating)
      end
      it {
        delete api_v1_credit_rating_path(@credit_rating), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina la calificación indicado' do
        expect do
          delete api_v1_credit_rating_path(@credit_rating), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(CreditRating, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @credit_rating = FactoryBot.create(:credit_rating)
        delete api_v1_credit_rating_path(@credit_rating),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
