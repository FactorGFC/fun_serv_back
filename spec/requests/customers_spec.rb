# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::CustomersController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor = FactoryBot.create(:contributor_with_customer)
    @file_type = FactoryBot.create(:file_type)
    @document = FactoryBot.create(:document)
    @file_type_document = FactoryBot.create(:file_type_document, file_type: @file_type, document: @document)
  end

  describe 'GET /contributors/:contributor_id/customers' do
    before :each do
      get "/api/v1/contributors/#{@contributor.id}/customers", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda el cliente del contribuyente' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(@contributor.customers.count)
    end

    it 'manda los datos del cliente' do
      json_array = JSON.parse(response.body)
      @customer = json_array['data'][0]
      expect(@customer['attributes'].keys).to contain_exactly('id', 'attached', 'customer_type', 'extra1', 'extra2',
                                                              'extra3', 'name', 'status', 'created_at', 'updated_at', 'contributor_id', 'user_id', 'file_type_id')
    end
  end

  describe 'GET /contributors/:contributor_id/customers/:id' do
    before :each do
      @customer = @contributor.customers[0]

      get api_v1_contributor_customer_path(@contributor, @customer),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el cliente solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@customer.id)
    end
  end

  describe 'POST /contributors/:contributor_id/customers' do
    context 'con usuario válido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_customers_path(@contributor),
             params: { customer: { name: 'Perdro Perez', customer_type: 'CF', status: 'AC',
                                   user_id: user.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de clientes +1' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_customers_path(@contributor),
               params: { customer: { name: 'Perdro Perez', customer_type: 'CF', status: 'AC',
                                     user_id: user.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(Customer, :count).by(1)
      end
      it 'responde con la cliente creada' do
        json = JSON.parse(response.body)
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>#{json}"
        expect(json['data']['attributes']['name']).to eq('Perdro Perez')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @contributor = FactoryBot.create(:contributor)
        post api_v1_contributor_customers_path(@contributor),
             params: { customer: { name: 'Perdro Perez', customer_type: 'Persona', status: 'AC',
                                   user_id: user.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de clientees +0' do
        expect do
          @contributor = FactoryBot.create(:contributor)
          post api_v1_contributor_customers_path(@contributor),
               params: { customer: { name: 'Perdro Perez', customer_type: 'Persona', status: 'AC',
                                     user_id: user.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(Customer, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /contributor/:contributor_id/customers/:id' do
    before :each do
      @customer = @contributor.customers[0]
      patch api_v1_contributor_customer_path(@contributor, @customer),
            params: { customer: { name: 'Pedro Acosta' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['name']).to eq('Pedro Acosta')
    end
  end

  describe 'DELETE /contributors/:contributor_id/customers/:id' do
    before :each do
      @customer = @contributor.customers[0]
    end

    it 'responde con estatus 200' do
      delete api_v1_contributor_customer_path(@contributor, @customer),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina la cliente' do
      delete api_v1_contributor_customer_path(@contributor, @customer),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(Customer.where(id: @customer.id)).to be_empty
    end

    it 'reduce el conteo de clientes en -1' do
      expect do
        delete api_v1_contributor_customer_path(@contributor, @customer),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(Customer, :count).by(-1)
    end
  end
end
