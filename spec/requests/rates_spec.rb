# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::RatesController, rate_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /rates' do
    before :each do
      FactoryBot.create_list(:rate, 10)
      get '/api/v1/rates', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de tasas' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Rate.count)
    end
  end

  describe 'GET /rates/:id' do
    before :each do
      @rate = FactoryBot.create(:rate)
      get "/api/v1/rates/#{@rate.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la tasa solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @rate.id
    end

    it 'manda los atributos de la tasa' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'key', 'description', 'value',
                                                                 'term_id', 'payment_period_id', 'credit_rating_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /rates' do
    context 'con token válido persona moral' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                        rate: { key: '12MAA', description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo tasa' do
        expect do
          post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                          rate: { key: '12MAA', description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                  term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
        end.to change(Rate, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('12MAA')
      end
    end

    context 'con token válido persona física' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                        rate: { key: '12MAA', description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo tasa' do
        expect do
          post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                          rate: { key: '12MAA', description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                  term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
        end.to change(Rate, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('12MAA')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/rates', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                        rate: { key: '12MAA', description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el tasa' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        post '/api/v1/rates', params: { token: @token.token, secret_key: @my_app.secret_key,
                                        rate: { description: 'Tasa de crédito a 12 pagos mensuales para AA', value: '12.50',
                                                term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el tasa' do
        json = JSON.parse(response.body)
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end
  end

  describe 'PATCH /rates/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @rate = FactoryBot.create(:rate)
        patch api_v1_rate_path(@rate), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                 rate: { key: 'AA12M' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el tasa indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('AA12M')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @rate = FactoryBot.create(:rate)
        patch api_v1_rate_path(@rate), params: { token: @token.token, secret_key: my_app.secret_key,
                                                 rate: { key: 'AA12M' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /rates' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @rate = FactoryBot.create(:rate)
      end
      it {
        delete api_v1_rate_path(@rate), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el tasa indicado' do
        expect do
          delete api_v1_rate_path(@rate), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Rate, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @rate = FactoryBot.create(:rate)
        delete api_v1_rate_path(@rate),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
