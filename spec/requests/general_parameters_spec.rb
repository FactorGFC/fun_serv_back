# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::GeneralParametersController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /general_parameters' do
    before :each do
      FactoryBot.create_list(:general_parameter, 10)
      get '/api/v1/general_parameters', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de parámetros' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(GeneralParameter.count)
    end
  end

  describe 'GET /general_parameters/:id' do
    before :each do
      @general_parameter = FactoryBot.create(:general_parameter)
      get "/api/v1/general_parameters/#{@general_parameter.id}",
          params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el parametro solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @general_parameter.id
    end

    it 'manda los atributos del parametro' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly(
        'id', 'table', 'id_table', 'key', 'description',
        'used_values', 'value', 'documentation', 'created_at',
        'updated_at'
      )
    end
  end

  describe 'POST /general_parameters' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/general_parameters', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                     general_parameter: { key: 'superusuario', description: 'Usuario principal de la aplicación', value: 'erodriguez' } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo rol' do
        expect do
          post '/api/v1/general_parameters', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                       general_parameter: { key: 'superusuario1', description: 'Usuario principal de la aplicación', value: 'erodriguez' } }
        end.to change(GeneralParameter, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('superusuario')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/general_parameters', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/general_parameters', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                     general_parameter: { key: 'superusuario', description: 'Usuario principal de la aplicación', value: 'erodriguez' } }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/general_parameters',
             params: { token: @token.token, secret_key: @my_app.secret_key, general_parameter: { key: 'superusuario' } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el parámetro' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /general_parameters/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @general_parameter = FactoryBot.create(:general_parameter)
        patch api_v1_general_parameter_path(@general_parameter),
              params: { token: @token.token, secret_key: @my_app.secret_key,
                        general_parameter: { description: 'Descripción actualizada' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el parámetro indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['description']).to eq('Descripción actualizada')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes,
                                           user: FactoryBot.create(:sequence_user))
        @general_parameter = FactoryBot.create(:general_parameter)
        patch api_v1_general_parameter_path(@general_parameter),
              params: { token: @token.token, secret_key: my_app.secret_key,
                        general_parameter: { description: 'Descripción actualizada' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /general_parameters' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @general_parameter = FactoryBot.create(:general_parameter)
      end
      it {
        delete api_v1_general_parameter_path(@general_parameter), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el paramero indicado' do
        expect do
          delete api_v1_general_parameter_path(@general_parameter), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(GeneralParameter, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @general_parameter = FactoryBot.create(:general_parameter)
        delete api_v1_general_parameter_path(@general_parameter),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
