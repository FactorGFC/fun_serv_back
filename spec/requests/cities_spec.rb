# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::CitiesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @state = FactoryBot.create(:state_with_cities)
  end

  describe 'GET /states/:state_id/cities' do
    before :each do
      get "/api/v1/states/#{@state.id}/cities", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de ciudades del estado' do
      json = JSON.parse(response.body)
      expect(json.length).to eq(@state.cities.count)
    end

    it 'manda los datos de la ciudad' do
      json_array = JSON.parse(response.body)
      @city = json_array['data'][0]
      expect(@city['attributes'].keys).to contain_exactly('id', 'state_id', 'name', 'created_at', 'updated_at')
    end
  end

  describe 'GET /states/:state_id/cities/:id' do
    before :each do
      @city = @state.cities[0]

      get api_v1_state_city_path(@state, @city),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'la ciudad solicitada en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['name']).to eq(@city.name)
    end
  end

  describe 'POST /states/:state_id/cities' do
    context 'con usuario válido' do
      before :each do
        post api_v1_state_cities_path(@state),
             params: { city: { name: 'Delicias' },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de ciudades +1' do
        expect do
          post api_v1_state_cities_path(@state),
               params: { city: { name: 'Delicias' },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(City, :count).by(1)
      end
      it 'responde con la ciudad creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Delicias')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_state_cities_path(@state),
             params: { city: { name: 'Delicias' },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de ciudades +0' do
        expect do
          post api_v1_state_cities_path(@state),
               params: { city: { name: 'Delicias' },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(City, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /state/:state_id/cities/:id' do
    before :each do
      @city = @state.cities[0]
      patch api_v1_state_city_path(@state, @city),
            params: { city: { name: 'Delicias actualizado' },
                      token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq('Delicias actualizado')
    end
  end

  describe 'DELETE /states/:state_id/cities/:id' do
    before :each do
      @city = @state.cities[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_state_city_path(@state, @city),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la ciudad' do
      delete api_v1_state_city_path(@state, @city),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(City.where(id: @city.id)).to be_empty
    end

    it 'reduce el conteo de ciudades en -1' do
      expect do
        delete api_v1_state_city_path(@state, @city),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(City, :count).by(-1)
    end
  end
end
