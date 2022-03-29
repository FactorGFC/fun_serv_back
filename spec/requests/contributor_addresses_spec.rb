# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::ContributorAddressesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor = FactoryBot.create(:contributor)
    @municipality = FactoryBot.create(:municipality)
    @state = FactoryBot.create(:state)
    @contributor_address = FactoryBot.create(:contributor_address, contributor: @contributor, municipality: @municipality,
                                                                   state: @state)
  end

  describe 'GET /contributors/:contributor_id/contributor_addresses' do
    before :each do
      get "/api/v1/contributors/#{@contributor.id}/contributor_addresses", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el domicmilio asociado' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(ContributorAddress.count)
    end

    it 'manda los datos del domicilio' do
      json_array = JSON.parse(response.body)
      @contributor_address = json_array['data'][0]
      expect(@contributor_address['attributes'].keys).to contain_exactly('id', 'address_reference', 'address_type', 'external_number', 'apartment_number', 'postal_code', 'street', 'suburb', 'suburb_type', 'contributor_id', 'municipality_id', 'state_id', 'created_at', 'updated_at')
    end
  end

  describe 'GET /contributors/:contributor_id/contributor_addresses/:id' do
    before :each do
      get api_v1_contributor_contributor_address_path(@contributor, @contributor_address),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el domicilio solicitada en JSON' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['id']).to eq(@contributor_address.id)
    end
  end

  describe 'POST /contributors/:contributor_id/contributor_addresses' do
    context 'con usuario válido' do
      before :each do
        @municipality = FactoryBot.create(:municipality)
        @state = FactoryBot.create(:state)
        post api_v1_contributor_contributor_addresses_path(@contributor),
             params: { contributor_address: { address_type: 'Domicilio particular', street: 'Portal Colonial', external_number: 527,
                                              apartment_number: 'A', suburb_type: 'Urbano', suburb: 'Portales', postal_code: 31_115,
                                              address_reference: 'Entre 1 y 2', municipality_id: @municipality.id, state_id: @state.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de domicilios +1' do
        expect do
          post api_v1_contributor_contributor_addresses_path(@contributor),
               params: { contributor_address: { address_type: 'Domicilio particular', street: 'Portal Colonial', external_number: 527,
                                                apartment_number: 'A', suburb_type: 'Urbano', suburb: 'Portales', postal_code: 31_115,
                                                address_reference: 'Entre 1 y 2', municipality_id: @municipality.id, state_id: @state.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end        .to change(ContributorAddress, :count).by(1)
      end
      it 'responde con el domicilio creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['address_type']).to eq('Domicilio particular')
      end
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_contributor_contributor_addresses_path(@contributor),
             params: { contributor_address: { address_type: 'Domicilio particular', street: 'Portal Colonial', external_number: 527,
                                              apartment_number: 'A', suburb_type: 'Urbano', suburb: 'Portales', postal_code: 31_115,
                                              address_reference: 'Entre 1 y 2', municipality_id: @municipality.id, state_id: @state.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de domicilios +0' do
        expect do
          post api_v1_contributor_contributor_addresses_path(@contributor),
               params: { contributor_address: { address_type: 'Domicilio particular', street: 'Portal Colonial', external_number: 527,
                                                apartment_number: 'A', suburb_type: 'Urbano', suburb: 'Portales', postal_code: 31_115,
                                                address_reference: 'Entre 1 y 2', municipality_id: @municipality.id, state_id: @state.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end .to change(ContributorAddress, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/contributor_addresses/:id' do
    before :each do
      patch api_v1_contributor_contributor_address_path(@contributor, @contributor_address),
            params: { contributor_address: { address_type: 'Domicilio Fiscal' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['address_type']).to eq('Domicilio Fiscal')
    end
  end

  describe 'DELETE /contributors/:contributor_id/contributor_addresses/:id' do
    it 'responde con estatus 200' do
      delete api_v1_contributor_contributor_address_path(@contributor, @contributor_address),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el domicilio' do
      delete api_v1_contributor_contributor_address_path(@contributor, @contributor_address),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(ContributorAddress.where(id: @contributor_address.id)).to be_empty
    end

    it 'reduce el conteo de domicilios en -1' do
      expect do
        delete api_v1_contributor_contributor_address_path(@contributor, @contributor_address),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(ContributorAddress, :count).by(-1)
    end
  end
end
