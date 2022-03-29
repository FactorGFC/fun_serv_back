# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::CountriesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /countries' do
    before :each do
      FactoryBot.create_list(:country, 1)
      get '/api/v1/countries', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'manda la lista de Paises' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Country.count)
    end
  end

  describe 'GET /countries/:id' do
    before :each do
      @country = FactoryBot.create(:country)
      get "/api/v1/countries/#{@country.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el país solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @country.id
    end

    it 'manda los atributos del país' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'sortname', 'name', 'phonecode', 'created_at', 'updated_at')
    end
  end
end
