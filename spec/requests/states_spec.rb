# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::StatesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @country = FactoryBot.create(:country_with_states)
  end

  describe 'GET /countries/:country_id/states' do
    before :each do
      get "/api/v1/countries/#{@country.id}/states", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de estados de un país' do
      json = JSON.parse(response.body)
      expect(json.length).to eq(@country.states.count)
    end

    it 'manda los datos del estado' do
      json_array = JSON.parse(response.body)
      @state = json_array['data'][0]
      expect(@state['attributes'].keys).to contain_exactly('id', 'country_id', 'state_key', 'name', 'created_at', 'updated_at')
    end
  end

  describe 'GET /countries/:country_id/states/:id' do
    before :each do
      @state = @country.states[0]

      get api_v1_country_state_path(@country, @state),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el estado solicitado en JSON' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['id']).to eq(@state.id)
    end
  end
end
