# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::CustomerPersonalReferencesController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @customer = FactoryBot.create(:customer)
    @customer_personal_reference = FactoryBot.create(:customer_personal_reference, customer: @customer)
  end

  describe 'GET /customer_personal_references' do
    before :each do
      get '/api/v1/customer_personal_references', params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }

    it 'manda la referncia personal asociada' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(CustomerPersonalReference.count)
    end

    it 'manda los datos del la refencia personal' do
      json_array = JSON.parse(response.body)
      @customer_personal_reference = json_array['data'][0]
      expect(@customer_personal_reference['attributes'].keys).to contain_exactly('id', 'first_name', 'last_name', 'second_last_name', 'address', 'phone', 'reference_type', 'customer_id',
                                                                                 'created_at', 'updated_at')
    end
  end

  describe 'GET /customer_personal_references/:id' do
    before :each do
      get "/api/v1/customer_personal_references/#{@customer_personal_reference.id}", params: { token: @token.token, secret_key: my_app.secret_key }
      #  get api_v1_customer_personal_refence_path(@customer_personal_reference),
      #     params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'la referencia solicitada en JSON' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['id']).to eq(@customer_personal_reference.id)
    end
  end

  describe 'POST /customer_personal_references' do
    context 'con usuario valido' do
      before :each do
        @customer = FactoryBot.create(:customer)
        # @customer_personal_references = FactoryBot.create(:customer_personal_references, customer :@customer)
        post '/api/v1/customer_personal_references',
             params: { customer_personal_reference: { first_name: 'Oscar', last_name: 'Galvan', second_last_name: 'Loera',
                                                      address: 'Calle las Aguilas #2234', phone: '6145829673', reference_type: 'Familiar',
                                                      customer_id: @customer.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(200) }

      it 'cambia el numero de referncias +1' do
        expect do
          post '/api/v1/customer_personal_references',
               params: { customer_personal_reference: { first_name: 'Oscar', last_name: 'Galvan', second_last_name: 'Loera',
                                                        address: 'Calle las Aguilas #2234', phone: '6145829673', reference_type: 'Familiar',
                                                        customer_id: @customer.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(CustomerPersonalReference, :count).by(1)
      end

      it 'responde con la referncia creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['first_name']).to eq('Oscar')
      end
    end

    context 'con usuario invalido' do
      before :each do
        post '/api/v1/customer_personal_references',
             params: { customer_personal_reference: { first_name: 'Oscar', last_name: 'Galvan', second_last_name: 'Loera',
                                                      address: 'Calle las Aguilas #2234', phone: '6145829673', reference_type: 'Familiar',
                                                      customer_id: @customer.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el numero de referencias +0' do
        expect do
          post '/api/v1/customer_personal_references',
               params: { customer_personal_reference: { first_name: 'Oscar', last_name: 'Galvan', second_last_name: 'Loera',
                                                        address: 'Calle las Aguilas #2234', phone: '6145829673', reference_type: 'Familiar',
                                                        customer_id: @customer.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(CustomerPersonalReference, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /customer_personal_references/:id' do
    before :each do
      patch api_v1_customer_personal_reference_path(@customer_personal_reference),
            params: { customer_personal_reference: { first_name: 'Manuel' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['first_name']).to eq('Manuel')
    end
  end

  describe 'DELETE /customer_personal_references' do
    it 'responde con estatus 200' do
      delete api_v1_customer_personal_reference_path(@customer_personal_reference),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la referencia' do
      delete api_v1_customer_personal_reference_path(@customer_personal_reference),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(CustomerPersonalReference.where(id: @customer_personal_reference.id)).to be_empty
    end

    it 'reduce el conteo de las referencias en -1' do
      expect do
        delete api_v1_customer_personal_reference_path(@customer_personal_reference),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(CustomerPersonalReference, :count).by(-1)
    end
  end
end
