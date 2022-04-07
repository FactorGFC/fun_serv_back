# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CompaniesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor = FactoryBot.create(:contributor_with_company)
  end

  describe 'GET /contributors/:contributor_id/companies' do
    before :each do
      get "/api/v1/contributors/#{@contributor.id}/companies", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la cadena del contribuyente' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(@contributor.companies.count)
    end

    it 'manda los datos de la cadena' do
      json_array = JSON.parse(response.body)
      @company = json_array['data'][0]
      expect(@company['attributes'].keys).to contain_exactly('id', 'business_name', 'start_date', 'credit_limit', 'credit_available',
                                                             'balance', 'document', 'sector', 'subsector', 'company_rate', 'created_at', 'updated_at', 'contributor_id')
    end
  end

  describe 'GET /contributors/:contributor_id/companies/:id' do
    before :each do
      @company = @contributor.companies[0]

      get api_v1_contributor_company_path(@contributor, @company),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'la cadena solicitada en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@company.id)
    end
  end

  describe 'POST /contributors/:contributor_id/companies' do
    context 'con usuario válido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_companies_path(@contributor),
             params: { company: { business_name: 'Bancomer', start_date: '2020-01-01', credit_limit: '1000000.8888',
                                  credit_available: '10000.8888', document: 'document', sector: 'sector', subsector: 'subsector', company_rate: '18.5' },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de cadenas +1' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_companies_path(@contributor),
               params: { company: { business_name: 'Bancomer', start_date: '2020-01-01', credit_limit: '1000000.8888',
                                    credit_available: '1000000.8888', document: 'document', sector: 'sector', subsector: 'subsector', company_rate: '18.5' },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(Company, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['business_name']).to eq('Bancomer')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_companies_path(@contributor),
             params: { company: { business_name: 'Bancomer', start_date: '2020-01-01', credit_limit: '1000000.8888',
                                  credit_available: '10000.8888', document: 'document', sector: 'sector', subsector: 'subsector' },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de cadenas +0' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_companies_path(@contributor),
               params: { company: { business_name: 'Bancomer', start_date: '2020-01-01', credit_limit: '1000000.8888',
                                    credit_available: '10000.8888', document: 'document', sector: 'sector', subsector: 'subsector' },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(Company, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/companies/:id' do
    before :each do
      @company = @contributor.companies[0]
      patch api_v1_contributor_company_path(@contributor, @company),
            params: { company: { business_name: 'Bancomer actualizado' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['business_name']).to eq('Bancomer actualizado')
    end
  end

  describe 'DELETE /contributors/:contributor_id/companies/:id' do
    before :each do
      @company = @contributor.companies[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_contributor_company_path(@contributor, @company),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la cadena' do
      delete api_v1_contributor_company_path(@contributor, @company),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(Company.where(id: @company.id)).to be_empty
    end

    it 'reduce el conteo de cadenas en -1' do
      expect do
        delete api_v1_contributor_company_path(@contributor, @company),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(Company, :count).by(-1)
    end
  end
end
