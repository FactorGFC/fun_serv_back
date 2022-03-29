# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::FundersController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor = FactoryBot.create(:contributor_with_funder)
    @file_type = FactoryBot.create(:file_type)
    @document = FactoryBot.create(:document)
    @file_type_document = FactoryBot.create(:file_type_document, file_type: @file_type, document: @document)
  end

  describe 'GET /contributors/:contributor_id/funders' do
    before :each do
      get "/api/v1/contributors/#{@contributor.id}/funders", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el inversionista del contribuyente' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(@contributor.funders.count)
    end

    it 'manda los datos del inversionista' do
      json_array = JSON.parse(response.body)
      @funder = json_array['data'][0]
      expect(@funder['attributes'].keys).to contain_exactly('id', 'attached', 'funder_type', 'extra1', 'extra2',
                                                            'extra3', 'name', 'status', 'created_at', 'updated_at', 'contributor_id', 'user_id', 'file_type_id')
    end
  end

  describe 'GET /contributors/:contributor_id/funders/:id' do
    before :each do
      @funder = @contributor.funders[0]

      get api_v1_contributor_funder_path(@contributor, @funder),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el inversionista solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@funder.id)
    end
  end

  describe 'POST /contributors/:contributor_id/funders' do
    context 'con usuario válido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_funders_path(@contributor),
             params: { funder: { name: 'Perdro Perez', funder_type: 'FF', status: 'AC',
                                 user_id: user.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de inversionistas +1' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_funders_path(@contributor),
               params: { funder: { name: 'Perdro Perez', funder_type: 'FF', status: 'AC',
                                   user_id: user.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(Funder, :count).by(1)
      end
      it 'responde con la inversionista creada' do
        json = JSON.parse(response.body)
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{json}"
        expect(json['data']['attributes']['name']).to eq('Perdro Perez')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_funders_path(@contributor),
             params: { funder: { name: 'Perdro Perez', funder_type: 'Persona', status: 'AC',
                                 user_id: user.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de inversionistaes +0' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_funders_path(@contributor),
               params: { funder: { name: 'Perdro Perez', funder_type: 'Persona', status: 'AC',
                                   user_id: user.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(Funder, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/funders/:id' do
    before :each do
      @funder = @contributor.funders[0]
      patch api_v1_contributor_funder_path(@contributor, @funder),
            params: { funder: { name: 'Pedro Acosta' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq('Pedro Acosta')
    end
  end

  describe 'DELETE /contributors/:contributor_id/funders/:id' do
    before :each do
      @funder = @contributor.funders[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_contributor_funder_path(@contributor, @funder),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la inversionista' do
      delete api_v1_contributor_funder_path(@contributor, @funder),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(Funder.where(id: @funder.id)).to be_empty
    end

    it 'reduce el conteo de inversionistas en -1' do
      expect do
        delete api_v1_contributor_funder_path(@contributor, @funder),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(Funder, :count).by(-1)
    end
  end
end
