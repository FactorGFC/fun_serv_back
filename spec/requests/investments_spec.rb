# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::InvestmentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @funding_requests = FactoryBot.create(:funding_request_with_investments)
  end

  describe 'GET /funding_requests/:funding_request_id/investments' do
    before :each do
      get "/api/v1/funding_requests/#{@funding_requests.id}/investments", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de inversiones de la solicitud de fondeo' do
      json = JSON.parse(response.body)
      expect(json.length).to eq(@funding_requests.investments.count)
    end

    it 'manda los datos de la inversión' do
      json_array = JSON.parse(response.body)
      @investment = json_array['data'][0]
      expect(@investment['attributes'].keys).to contain_exactly('id', 'total', 'rate', 'investment_date', 'status', 'attached', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'funding_request_id', 'funder_id', 'yield_fixed_payment')
    end
  end

  describe 'GET /funding_requests/:funding_request_id/investments/:id' do
    before :each do
      @investment = @funding_requests.investments[0]

      get api_v1_funding_request_investment_path(@funding_requests, @investment),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'manda la inversión solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @investment.id
    end
  end

  describe 'POST /funding_requests/:funding_request_id/investments' do
    context 'con usuario válido' do
      before :each do
        @funder = FactoryBot.create(:funder)
        post api_v1_funding_request_investments_path(@funding_requests),
             params: { investment: { total: '10000.00', rate: '13.50', investment_date: '2021-02-01', status: 'AC', attached: 'http://investment.pdf', funder_id: @funder.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de inversiones +1' do
        expect do
          @funder = FactoryBot.create(:funder)
          post api_v1_funding_request_investments_path(@funding_requests),
               params: { investment: { total: '10000.00', rate: '13.50', investment_date: '2021-02-01', status: 'AC', attached: 'http://investment.pdf', funder_id: @funder.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(Investment, :count).by(1)
      end
      it 'responde con la inversión creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('AC')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @funder = FactoryBot.create(:funder)
          post api_v1_funding_request_investments_path(@funding_requests),
               params: { investment: { total: '10000.00', rate:'13.50', investment_date: '2021-02-01', status: 'AC', attached: 'http://investment.pdf', funder_id: @funder.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de inversiones +0' do
        expect do
          @funder = FactoryBot.create(:funder)
          post api_v1_funding_request_investments_path(@funding_requests),
               params: { investment: { total: '10000.00', rate:'13.50', investment_date: '2021-02-01', status: 'AC', attached: 'http://investment.pdf', funder_id: @funder.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(Investment, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /user/:funding_request_id/investments/:id' do
    before :each do
      @investment = @funding_requests.investments[0]
      patch api_v1_funding_request_investment_path(@funding_requests, @investment),
            params: { investment: { status: 'TE' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['status']).to eq('TE')
    end
  end

  describe 'DELETE /funding_requests/:funding_request_id/investments/:id' do
    before :each do
      @investment = @funding_requests.investments[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_funding_request_investment_path(@funding_requests, @investment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la inversión' do
      delete api_v1_funding_request_investment_path(@funding_requests, @investment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(Investment.where(id: @investment.id)).to be_empty
    end

    it 'reduce el conteo de inversiones en -1' do
      expect do
        delete api_v1_funding_request_investment_path(@funding_requests, @investment),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(Investment, :count).by(-1)
    end
  end
end
