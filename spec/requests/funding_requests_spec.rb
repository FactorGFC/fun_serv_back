# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::FundingRequestsController, funding_request_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /funding_requests' do
    before :each do
      FactoryBot.create_list(:funding_request, 10)
      get '/api/v1/funding_requests', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de solicitudes de fondeos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(FundingRequest.count)
    end
  end

  describe 'GET /funding_requests/:id' do
    before :each do
      @funding_request = FactoryBot.create(:funding_request)
      get "/api/v1/funding_requests/#{@funding_request.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la solicitud de fondeo solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @funding_request.id
    end

    it 'manda los atributos de la solicitud de fondeo' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'total_requested', 'total_investments', 'balance', 'funding_request_date', 'funding_due_date', 'status', 'attached', 
                                                                 'project_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /funding_requests' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)        
        @project = FactoryBot.create(:project) 
        post '/api/v1/funding_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               funding_request: { total_requested: '100000.00', total_investments: '0.00', balance: '100000.00', funding_request_date: '2021-02-01', funding_due_date: '2021-04-01', status: 'AC', 
                                                                  attached: 'http://localhost/funding_request/12545.pdf', project_id: @project.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo solicitudes de fondeo' do
        expect do
          post '/api/v1/funding_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                     funding_request: { total_requested: '100000.00', total_investments: '0.00', balance: '100000.00', funding_request_date: '2021-02-01', funding_due_date: '2021-04-01', status: 'AC', 
                                                                        attached: 'http://localhost/funding_request/12545.pdf', project_id: @project.id } }
        end.to change(FundingRequest, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('AC')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/funding_requests', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @project = FactoryBot.create(:project)
        post '/api/v1/funding_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                   funding_request: { total_requested: '100000.00', total_investments: '0.00', balance: '100000.00', funding_request_date: '2021-02-01', funding_due_date: '2021-04-01', status: 'AC', 
                                                                      attached: 'http://localhost/funding_request/12545.pdf', project_id: @project.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el solicitudes de fondeo' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project = FactoryBot.create(:project)
        post '/api/v1/funding_requests', params: { token: @token.token, secret_key: @my_app.secret_key,
          funding_request: { total_investments: '0.00', balance: '100000.00', funding_request_date: '2021-02-01', funding_due_date: '2021-04-01', status: 'AC', 
            attached: 'http://localhost/funding_request/12545.pdf', project_id: @project.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el solicitudes de fondeo' do
        json = JSON.parse(response.body)
        #puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end
  end  

  describe 'PATCH /funding_requests/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @funding_request = FactoryBot.create(:funding_request)
        patch api_v1_funding_request_path(@funding_request), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                               funding_request: { status: 'PA' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza las solicitudes de fondeo indicadas' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('PA')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @funding_request = FactoryBot.create(:funding_request)
        patch api_v1_funding_request_path(@funding_request), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               funding_request: { status: 'RE' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /funding_requests' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @funding_request = FactoryBot.create(:funding_request)
      end
      it {
        delete api_v1_funding_request_path(@funding_request), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina las solicitudes de fondeo indicadas' do
        expect do
          delete api_v1_funding_request_path(@funding_request), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(FundingRequest, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @funding_request = FactoryBot.create(:funding_request)
        delete api_v1_funding_request_path(@funding_request),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
