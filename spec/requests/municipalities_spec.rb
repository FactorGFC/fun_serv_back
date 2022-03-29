# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::MunicipalitiesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @state = FactoryBot.create(:state_with_municipalities)
  end

  describe 'GET /states/:state_id/municipalities' do
    before :each do
      get "/api/v1/states/#{@state.id}/municipalities", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de municipios del estado' do
      json = JSON.parse(response.body)
      expect(json.length).to eq(@state.municipalities.count)
    end

    it 'manda los datos del municipio' do
      json_array = JSON.parse(response.body)
      @municipality = json_array['data'][0]
      expect(@municipality['attributes'].keys).to contain_exactly('id', 'state_id', 'municipality_key', 'name', 'created_at', 'updated_at')
    end
  end

  describe 'GET /states/:state_id/municipalities/:id' do
    before :each do
      @municipality = @state.municipalities[0]

      get api_v1_state_municipality_path(@state, @municipality),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el municipio solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['name']).to eq(@municipality.name)
    end
  end

  describe 'POST /states/:state_id/municipalities' do
    context 'con usuario válido' do
      before :each do
        post api_v1_state_municipalities_path(@state),
             params: { municipality: { municipality_key: '85', name: 'Delicias' },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de municipios +1' do
        expect do
          post api_v1_state_municipalities_path(@state),
          params: { municipality: { municipality_key: '85', name: 'Delicias' },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(Municipality, :count).by(1)
      end
      it 'responde con el municipio creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Delicias')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_state_municipalities_path(@state),
        params: { municipality: { municipality_key: '85', name: 'Delicias' },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de municipios +0' do
        expect do
          post api_v1_state_municipalities_path(@state),
          params: { municipality: { municipality_key: '85', name: 'Delicias' },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(Municipality, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /state/:state_id/municipalities/:id' do
    before :each do
      @municipality = @state.municipalities[0]
      patch api_v1_state_municipality_path(@state, @municipality),
            params: { municipality: { name: 'Delicias actualizado' },
                      token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq('Delicias actualizado')
    end
  end

  describe 'DELETE /states/:state_id/municipalities/:id' do
    before :each do
      @municipality = @state.municipalities[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_state_municipality_path(@state, @municipality),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el municipio' do
      delete api_v1_state_municipality_path(@state, @municipality),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(Municipality.where(id: @municipality.id)).to be_empty
    end

    it 'reduce el conteo de municipios en -1' do
      expect do
        delete api_v1_state_municipality_path(@state, @municipality),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(Municipality, :count).by(-1)
    end
  end
end
