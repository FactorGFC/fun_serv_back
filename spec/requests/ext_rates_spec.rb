# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ExtRatesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /ext_rates' do
    before :each do
      FactoryBot.create_list(:ext_rate, 1)
      get '/api/v1/ext_rates', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de tarifas' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(ExtRate.count)
    end
  end

  describe 'GET /ext_rates/:id' do
    before :each do
      @ext_rate = FactoryBot.create(:ext_rate)
      get "/api/v1/ext_rates/#{@ext_rate.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la tarifa solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @ext_rate.id
    end

    it 'manda los atributos de la tarifa' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'key', 'description', 'start_date', 'end_date', 'value', 'rate_type', 'max_value', 'created_at', 'updated_at')
    end
  end

  describe 'POST /ext_rates' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/ext_rates', params: { token: @token.token, secret_key: @my_app.secret_key, ext_rate: {
          key: 'tiie_28dias', description: 'Tasa de interés interbancaria a 28 días', start_date: '2020-06-02',
          end_date: '2020-06-02', value: '5.7347', rate_type: 'porcentaje'
        } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea una nueva tarifa' do
        expect do
          post '/api/v1/ext_rates', params: { token: @token.token, secret_key: @my_app.secret_key, ext_rate: {
            key: 'libor_1m', description: 'Tasa de interés de banco de londres a 1 mes', start_date: '2020-06-02',
            end_date: '2020-06-02', value: '5.7347', rate_type: 'porcentaje'
          } }
        end.to change(ExtRate, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('tiie_28dias')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/ext_rates', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/ext_rates', params: { token: @token.token, secret_key: @my_app.secret_key,  ext_rate: {
          key: 'tiie_28dias', description: 'Tasa de interés interbancaria a 28 días', start_date: '2020-06-02',
          end_date: '2020-06-02', value: '5.7347', rate_type: 'porcentaje'
        } }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/ext_rates', params: { token: @token.token, ext_rate: { description: 'Tasa de interés interbancaria a 28 días' }, secret_key: @my_app.secret_key }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar la tarifa' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /ext_rates/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_rate = FactoryBot.create(:ext_rate)
        patch api_v1_ext_rate_path(@ext_rate), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                         ext_rate: { description: 'Tasa de interés interbancaria a 28 días' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza la tarifa indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Tasa de interés interbancaria a 28 días')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @ext_rate = FactoryBot.create(:ext_rate)
        patch api_v1_ext_rate_path(@ext_rate), params: { token: @token.token, secret_key: my_app.secret_key,
                                                         ext_rate: { description: 'Tasa de interés interbancaria a 28 días' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /ext_rates' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_rate = FactoryBot.create(:ext_rate)
      end
      it {
        delete api_v1_ext_rate_path(@ext_rate), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina la tarifa indicada' do
        expect do
          delete api_v1_ext_rate_path(@ext_rate), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(ExtRate, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @ext_rate = FactoryBot.create(:ext_rate)
        delete api_v1_ext_rate_path(@ext_rate),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
