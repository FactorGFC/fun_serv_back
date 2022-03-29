# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ProjectRequestsController, project_request_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /project_requests' do
    before :each do
      FactoryBot.create_list(:project_request, 10)
      get '/api/v1/project_requests', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de solicitudes de proyecto' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(ProjectRequest.count)
    end
  end

  describe 'GET /project_requests/:id' do
    before :each do
      @project_request = FactoryBot.create(:project_request)
      get "/api/v1/project_requests/#{@project_request.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la solicitud de proyecto solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @project_request.id
    end

    it 'manda los atributos de la solicitud de proyecto' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'project_type', 'folio', 'currency', 'total', 'request_date', 'status', 'attached',
                                                                 'customer_id', 'user_id', 'term_id', 'payment_period_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'rate')
    end
  end

  describe 'POST /project_requests' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id)
        post '/api/v1/project_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               project_request: { project_type: 'CR', folio: 'CR123654dsfsd456', currency: 'MN', total: '100000.00', request_date: '2021-02-01', status: 'ER', attached: 'https://anexo.pdf',
                                                       customer_id: @customer.id, user_id: user.id, term_id: @term.id, payment_period_id: @payment_period.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo solicitud de proyecto' do
        expect do
          post '/api/v1/project_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
            project_request: { project_type: 'CR', folio: 'CR123654dsfsd456', currency: 'MN', total: '100000.00', request_date: '2021-02-01', status: 'ER', attached: 'https://anexo.pdf',
              customer_id: @customer.id, user_id: user.id, term_id: @term.id, payment_period_id: @payment_period.id } }
        end.to change(ProjectRequest, :count).by(1)
      end
      it 'responde con el proyecto creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['project_type']).to eq('CR')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/project_requests', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id)
        post '/api/v1/project_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
          project_request: { project_type: 'CR', folio: 'CR123654dsfsd456', currency: 'MN', total: '100000.00', request_date: '2021-02-01', status: 'ER', attached: 'https://anexo.pdf',
            customer_id: @customer.id, user_id: user.id, term_id: @term.id, payment_period_id: @payment_period.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el solicitud de proyecto' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id)
        post '/api/v1/project_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
          project_request: { folio: 'CR123654dsfsd456', currency: 'MN', total: '100000.00', request_date: '2021-02-01', status: 'ER', attached: 'https://anexo.pdf',
            customer_id: @customer.id, user_id: user.id, term_id: @term.id, payment_period_id: @payment_period.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el solicitud de proyecto' do
        json = JSON.parse(response.body)
        #puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end
  end  

  describe 'PATCH /project_requests/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project_request = FactoryBot.create(:project_request)
        patch api_v1_project_request_path(@project_request), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                               project_request: { status: 'RE' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el solicitud de proyecto indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('RE')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @project_request = FactoryBot.create(:project_request)
        patch api_v1_project_request_path(@project_request), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               project_request: { status: 'RE' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /project_requests' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project_request = FactoryBot.create(:project_request)
      end
      it {
        delete api_v1_project_request_path(@project_request), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina la solicitud de proyecto indicada' do
        expect do
          delete api_v1_project_request_path(@project_request), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(ProjectRequest, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project_request = FactoryBot.create(:project_request)
        delete api_v1_project_request_path(@project_request),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
