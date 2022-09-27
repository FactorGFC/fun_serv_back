# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::CreditBureausController, credit_bureaus_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /credit_bureaus' do
    before :each do
      FactoryBot.create_list(:credit_bureau, 10)
      get '/api/v1/credit_bureaus', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'espera que mande la lista de credit_bureaus' do
      json = JSON.parse(response.body)
      puts json
      expect(json.length).to eq(CreditBureau.count)
    end
  end
end