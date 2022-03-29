# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::PaymentPeriodsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /payment_periods' do
    before :each do
      FactoryBot.create_list(:payment_period, 10)
      get '/api/v1/payment_periods', params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de tipo de pagos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(PaymentPeriod.count)
    end
  end

  describe 'GET /payment_periods/:id' do
    before :each do
      @payment_period = FactoryBot.create(:payment_period)
      get "/api/v1/payment_periods/#{@payment_period.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el tipo de pago solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @payment_period.id
    end
    it 'manda los atributos del tipo de pago' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'key', 'description', 'value', 'pp_type', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /payment_periods' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/payment_periods', params: { token: @token.token, secret_key: @my_app.secret_key, payment_period:
                                                    { key: 'Mensual', description: 'Mensual', value: 12, pp_type: 'ME' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo tipo de pago' do
        expect do
          post '/api/v1/payment_periods', params: { token: @token.token, secret_key: @my_app.secret_key, payment_period:
                                                  { key: 'Mensual', description: 'Mensual', value: 12, pp_type: 'ME' } }
        end.to change(PaymentPeriod, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('Mensual')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/payment_periods', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/payment_periods', params: { token: @token.token, secret_key: @my_app.secret_key, payment_period:
                                                      { key: 'Mensual', description: 'Mensual', value: 12, pp_type: 'ME' } }
      end
    end
  end

  describe 'PATCH /payment_periods/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @payment_period = FactoryBot.create(:payment_period)
        patch api_v1_payment_period_path(@payment_period), params: { token: @token.token, secret_key: @my_app.secret_key, payment_period: { key: 'Anual' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'actualiza el tipo de pago indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('Anual')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @payment_period = FactoryBot.create(:payment_period)
        patch api_v1_payment_period_path(@payment_period), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                     payment_period: { key: 'Anual' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /tipo de pagos' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @payment_period = FactoryBot.create(:payment_period)
      end
      it {
        delete api_v1_payment_period_path(@payment_period), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }
      it 'elimina el tipo de pago indicado' do
        expect do
          delete api_v1_payment_period_path(@payment_period), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(PaymentPeriod, :count).by(-1)
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @payment_period = FactoryBot.create(:payment_period)
        delete api_v1_payment_period_path(@payment_period),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
