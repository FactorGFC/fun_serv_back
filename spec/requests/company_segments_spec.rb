# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::CompanySegmentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor = FactoryBot.create(:contributor)
    @company = FactoryBot.create(:company_with_segments, contributor: @contributor)
  end

  describe 'GET /companies/:company_id/company_segments' do
    before :each do
      get "/api/v1/companies/#{@company.id}/company_segments", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de segmentos de la cadena' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(@company.company_segments.count)
    end

    it 'manda los datos del segmento' do
      json_array = JSON.parse(response.body)
      @company_segment = json_array['data'][0]
      expect(@company_segment['attributes'].keys).to contain_exactly('id', 'key', 'company_rate', 'credit_limit', 'max_period', 'commission', 'currency', 'extra1','extra2','extra3',
                                                                     'created_at', 'updated_at', 'company_id')
    end
  end

  describe 'GET /companies/:company_id/company_segments/:id' do
    before :each do
      @company_segment = @company.company_segments[0]

      get api_v1_company_company_segment_path(@company, @company_segment),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el segmento solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@company_segment.id)
    end
  end

  describe 'POST /companies/:company_id/company_segments' do
    context 'con usuario válido' do
      before :each do
        post api_v1_company_company_segments_path(@company),
             params: { company_segment: { key: 'Administrativo alto', company_rate: '16.0', credit_limit: '6.0', max_period: '36.0', commission: '0.0', 
                                         currency: 'PESOS' },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de segmentos +1' do
        expect do
          post api_v1_company_company_segments_path(@company),
               params: { company_segment: { key: 'Administrativo alto', company_rate: '16.0', credit_limit: '6.0', max_period: '36.0', commission: '0.0', 
               currency: 'PESOS' },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(CompanySegment, :count).by(1)
      end
      it 'respondel segmento creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['key']).to eq('Administrativo alto')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_company_company_segments_path(@company),
             params: { company_segment: {key: 'Administrativo alto', company_rate: '16.0', credit_limit: '6.0', max_period: '36.0', commission: '0.0', 
             currency: 'PESOS'  },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de segmentos +0' do
        expect do
          post api_v1_company_company_segments_path(@company),
               params: { company_segment: {key: 'Administrativo alto', company_rate: '16.0', credit_limit: '6.0', max_period: '36.0', commission: '0.0', 
               currency: 'PESOS' },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(CompanySegment, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/company_segments/:id' do
    before :each do
      @company_segment = @company.company_segments[0]
      patch api_v1_company_company_segment_path(@company, @company_segment),
            params: { company_segment: { key: 'Administrativo alto'}, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['key']).to eq('Administrativo alto')
    end
  end

  describe 'DELETE /companies/:company_id/company_segments/:id' do
    before :each do
      @company_segment = @company.company_segments[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_company_company_segment_path(@company, @company_segment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el segmento' do
      delete api_v1_company_company_segment_path(@company, @company_segment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(CompanySegment.where(id: @company_segment.id)).to be_empty
    end

    it 'reduce el conteo de segmentos en -1' do
      expect do
        delete api_v1_company_company_segment_path(@company, @company_segment),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(CompanySegment, :count).by(-1)
    end
  end
end
