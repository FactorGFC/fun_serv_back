# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ProjectsController, project_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /projects' do
    before :each do
      FactoryBot.create_list(:project, 10)
      get '/api/v1/projects', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista des proyectos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Project.count)
    end
  end

  describe 'GET /projects/:id' do
    before :each do
      @project = FactoryBot.create(:project)
      get "/api/v1/projects/#{@project.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el proyecto solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @project.id
    end

    it 'manda los atributos del proyecto' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'project_type', 'folio', 'client_rate', 'funder_rate', 'ext_rate', 'total', 'interests', 'financial_cost', 'currency', 'entry_date', 'used_date', 'status', 'attached',
                                                                 'customer_id', 'user_id', 'project_request_id', 'term_id', 'payment_period_id', 'credit_rating_id', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /projects' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @project_request = FactoryBot.create(:project_request)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id)
        FactoryBot.create(:gp_base_anual_dias)
        FactoryBot.create(:gp_funder_dif_rate)        
        post '/api/v1/projects', params: { token: @token.token, secret_key: @my_app.secret_key,
                                               project: { project_type: 'CR', folio: 'CR123654dsfsd456', client_rate: '18.50', funder_rate: '13.50', ext_rate: '5.50', total: '100000.00', interests: '1125.00', financial_cost: '1.75', currency: 'MN', entry_date: '2021-02-01', used_date: '2021-04-01', status: 'EF', attached: 'https://anexo.pdf',
                                                       customer_id: @customer.id, user_id: user.id, project_request_id: @project_request.id, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea un nuevo proyecto' do
        expect do
          post '/api/v1/projects', params: { token: @token.token, secret_key: @my_app.secret_key,
            project: { project_type: 'CR', folio: 'CR123654dsfsd456', client_rate: '18.50', funder_rate: '13.50', ext_rate: '5.50', total: '100000.00', interests: '1125.00', financial_cost: '1.75', currency: 'MN', entry_date: '2021-02-01', used_date: '2021-04-01', status: 'EF', attached: 'https://anexo.pdf',
              customer_id: @customer.id, user_id: user.id, project_request_id: @project_request.id, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
        end.to change(Project, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['project_type']).to eq('CR')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/projects', params: { secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        @customer = FactoryBot.create(:customer)
        @project_request = FactoryBot.create(:project_request)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id)
        FactoryBot.create(:gp_base_anual_dias)
        FactoryBot.create(:gp_funder_dif_rate)
        post '/api/v1/projects', params: { token: @token.token, secret_key: @my_app.secret_key,
          project: { project_type: 'CR', folio: 'CR123654dsfsd456', client_rate: '18.50', funder_rate: '13.50', ext_rate: '5.50', total: '100000.00', interests: '1125.00', financial_cost: '1.75', currency: 'MN', entry_date: '2021-02-01', used_date: '2021-04-01', status: 'EF', attached: 'https://anexo.pdf',
            customer_id: @customer.id, user_id: user.id, project_request_id: @project_request.id, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el proyecto' do
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
        @project_request = FactoryBot.create(:project_request)
        @term = FactoryBot.create(:term)
        @payment_period = FactoryBot.create(:payment_period)
        @credit_rating = FactoryBot.create(:credit_rating)
        @rate = FactoryBot.create(:rate, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id)
        FactoryBot.create(:gp_base_anual_dias)
        FactoryBot.create(:gp_funder_dif_rate)
        post '/api/v1/projects', params: { token: @token.token, secret_key: @my_app.secret_key,
          project: { folio: 'CR123654dsfsd456', client_rate: '18.50', funder_rate: '13.50', ext_rate: '5.50', total: '100000.00', interests: '1125.00', financial_cost: '1.75', currency: 'MN', entry_date: '2021-02-01', used_date: '2021-04-01', status: 'EF', attached: 'https://anexo.pdf',
            customer_id: @customer.id, user_id: user.id, project_request_id: @project_request.id, term_id: @term.id, payment_period_id: @payment_period.id, credit_rating_id: @credit_rating.id } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar el proyecto' do
        json = JSON.parse(response.body)
        #puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['errors']).to_not be_empty
      end
    end
  end  

  describe 'PATCH /projects/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project = FactoryBot.create(:project)
        patch api_v1_project_path(@project), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                               project: { status: 'RE' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el proyecto indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('RE')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @project = FactoryBot.create(:project)
        patch api_v1_project_path(@project), params: { token: @token.token, secret_key: my_app.secret_key,
                                                               project: { status: 'RE' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /projects' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project = FactoryBot.create(:project)
      end
      it {
        delete api_v1_project_path(@project), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el proyecto indicado' do
        expect do
          delete api_v1_project_path(@project), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Project, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @project = FactoryBot.create(:project)
        delete api_v1_project_path(@project),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
