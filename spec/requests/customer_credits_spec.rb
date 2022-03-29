# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::CustomerCreditsController, customer_credit_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /customer_credits' do
    before :each do
      FactoryBot.create_list(:customer_credit, 10)
      get '/api/v1/customer_credits', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista des credito al clientes' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(CustomerCredit.count)
    end
  end

  describe 'GET /customer_credits/:id' do
    before :each do
      @customer_credit = FactoryBot.create(:customer_credit)
      get "/api/v1/customer_credits/#{@customer_credit.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el credito al cliente solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @customer_credit.id
    end

    it 'manda los atributos del credito al cliente' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'total_requested', 'capital', 'interests', 'iva', 'total_debt', 'fixed_payment', 'total_payments', 'balance', 'status', 'start_date', 'end_date', 'attached',
                                                                 'customer_id', 'project_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'project_request_id', 'restructure_term')
    end
  end

  describe 'POST /customer_credits' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @project = FactoryBot.create(:project)
        post '/api/v1/customer_credits', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               customer_credit: { total_requested: '100000.00', capital: '100000.00', interests: '150000.00', iva: '16000.00', total_debt: '266000.00', total_payments: '0.00', balance: '266000.00', status: 'AC', start_date: '2021-02-01', end_date: '2021-04-01', attached: 'https://anexo.pdf',
                                               customer_id: @customer.id, project_id: @project.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo credito al cliente' do
        expect do
          post '/api/v1/customer_credits', params: { token: @token.token, secret_key: @my_app.secret_key,
            customer_credit: { total_requested: '100000.00', capital: '100000.00', interests: '150000.00', iva: '16000.00', total_debt: '266000.00', total_payments: '0.00', balance: '266000.00', status: 'AC', start_date: '2021-02-01', end_date: '2021-04-01', attached: 'https://anexo.pdf',
                               customer_id: @customer.id, project_id: @project.id } }
        end.to change(CustomerCredit, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('AC')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/customer_credits', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @project = FactoryBot.create(:project)
        post '/api/v1/customer_credits', params: { token: @token.token, secret_key: @my_app.secret_key,
          customer_credit: { total_requested: '100000.00', capital: '100000.00', interests: '150000.00', iva: '16000.00', total_debt: '266000.00', total_payments: '0.00', balance: '266000.00', status: 'AC', start_date: '2021-02-01', end_date: '2021-04-01', attached: 'https://anexo.pdf',
                             customer_id: @customer.id, project_id: @project.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el credito al cliente' do
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
        @project = FactoryBot.create(:project)
        post '/api/v1/customer_credits', params: { token: @token.token, secret_key: @my_app.secret_key,
          customer_credit: { capital: '100000.00', interests: '150000.00', iva: '16000.00', total_debt: '266000.00', total_payments: '0.00', balance: '266000.00', status: 'AC', start_date: '2021-02-01', end_date: '2021-04-01', attached: 'https://anexo.pdf',
                             customer_id: @customer.id, project_id: @project.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el credito al cliente' do
        json = JSON.parse(response.body)
        #puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end
  end  

  describe 'PATCH /customer_credits/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer_credit = FactoryBot.create(:customer_credit)
        patch api_v1_customer_credit_path(@customer_credit), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                               customer_credit: { status: 'PA' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el credito al cliente indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('PA')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @customer_credit = FactoryBot.create(:customer_credit)
        patch api_v1_customer_credit_path(@customer_credit), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               customer_credit: { status: 'PA' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /customer_credits' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer_credit = FactoryBot.create(:customer_credit)
      end
      it {
        delete api_v1_customer_credit_path(@customer_credit), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el credito al cliente indicado' do
        expect do
          delete api_v1_customer_credit_path(@customer_credit), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(CustomerCredit, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer_credit = FactoryBot.create(:customer_credit)
        delete api_v1_customer_credit_path(@customer_credit),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
