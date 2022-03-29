# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::SimFunderYieldsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @investment = FactoryBot.create(:investment)
    @sim_funder_yield = FactoryBot.create(:sim_funder_yield, investment: @investment)
  end

  describe 'GET /investments/:investment_id/sim_funder_yields' do
    before :each do
      get "/api/v1/investments/#{@investment.id}/sim_funder_yields", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de rendimientos de la inversión' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(SimFunderYield.count)
    end

    it 'manda los datos del rendimiento' do
      json_array = JSON.parse(response.body)
      @sim_funder_yield = json_array['data'][0]
      expect(@sim_funder_yield['attributes'].keys).to contain_exactly('id', 'yield_number', 'remaining_capital', 'capital', 'gross_yield', 'isr', 'net_yield', 'total', 'payment_date', 'status', 'attached', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'investment_id', 'funder_id', 'current_capital')
    end
  end

  describe 'GET /investments/:investment_id/sim_funder_yields/:id' do
    before :each do
      @sim_funder_yield = FactoryBot.create(:sim_funder_yield, investment: @investment)
      get api_v1_investment_sim_funder_yield_path(@investment, @sim_funder_yield),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el rendimiento solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@sim_funder_yield.id)
    end
  end

  describe 'POST /investments/:investment_id/sim_funder_yields' do
    context 'con usuario válido' do
      before :each do
        @funder = FactoryBot.create(:funder)
        @investment = FactoryBot.create(:investment)
        post api_v1_investment_sim_funder_yields_path(@investment),
             params: { sim_funder_yield: { yield_number: 1, remaining_capital: '200000.00', capital: '10000.00', gross_yield: '120.00', isr: '20.00', net_yield: '100.00', total: '10100.00', current_capital: '800.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_funder_yield.pdf', funder_id: @funder.id, investment_id: @investment.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de rendimientos +1' do
        expect do
          @funder = FactoryBot.create(:funder)
          @investment = FactoryBot.create(:investment)
          post api_v1_investment_sim_funder_yields_path(@investment),
              params: { sim_funder_yield: { yield_number: 1, remaining_capital: '200000.00', capital: '10000.00', gross_yield: '120.00', isr: '20.00', net_yield: '100.00', total: '10100.00', current_capital: '800.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_funder_yield.pdf', funder_id: @funder.id, investment_id: @investment.id },
                          token: @token.token, secret_key: my_app.secret_key }
        end        .to change(SimFunderYield, :count).by(1)
      end
      it 'responde con el rendimiento creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['status']).to eq('AC')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @funder = FactoryBot.create(:funder)
          @investment = FactoryBot.create(:investment)
        post api_v1_investment_sim_funder_yields_path(@investment),
              params: { sim_funder_yield: { yield_number: 1, remaining_capital: '200000.00', capital: '10000.00', gross_yield: '120.00', isr: '20.00', net_yield: '100.00', total: '10100.00', current_capital: '800.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_funder_yield.pdf', funder_id: @funder.id, investment_id: @investment.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de rendimientos +0' do
        expect do
          @funder = FactoryBot.create(:funder)
          @investment = FactoryBot.create(:investment)
          post api_v1_investment_sim_funder_yields_path(@investment),
              params: { sim_funder_yield: { yield_number: 1, remaining_capital: '200000.00', capital: '10000.00', gross_yield: '120.00', isr: '20.00', net_yield: '100.00', total: '10100.00', current_capital: '800.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_funder_yield.pdf', funder_id: @funder.id, investment_id: @investment.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(SimFunderYield, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /investment/:investment_id/sim_funder_yields/:id' do
    before :each do
      @sim_funder_yield = FactoryBot.create(:sim_funder_yield, investment: @investment)
      patch api_v1_investment_sim_funder_yield_path(@investment, @sim_funder_yield),
            params: { sim_funder_yield: { status: 'LI' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['status']).to eq('LI')
    end
  end

  describe 'DELETE /investments/:investment_id/sim_funder_yields/:id' do
    before :each do
      @sim_funder_yield = FactoryBot.create(:sim_funder_yield, investment: @investment)
    end

    it 'responde con estatus 200' do
      delete api_v1_investment_sim_funder_yield_path(@investment, @sim_funder_yield),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el rendimiento' do
      delete api_v1_investment_sim_funder_yield_path(@investment, @sim_funder_yield),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(SimFunderYield.where(id: @sim_funder_yield.id)).to be_empty
    end

    it 'reduce el conteo de rendimientos en -1' do
      expect do
        delete api_v1_investment_sim_funder_yield_path(@investment, @sim_funder_yield),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(SimFunderYield, :count).by(-1)
    end
  end
end
