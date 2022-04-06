# frozen_string_literal: true

require 'rails_helper'
# require 'factory_bot'

RSpec.describe Api::V1::SimCustomerPaymentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @customer_credit = FactoryBot.create(:customer_credit)
    @sim_customer_payment = FactoryBot.create(:sim_customer_payment, customer_credit: @customer_credit)
  end

  describe 'GET /customer_credits/:customer_credit_id/sim_customer_payments' do
    before :each do
      get "/api/v1/customer_credits/#{@customer_credit.id}/sim_customer_payments", params: { token: @token.token, secret_key: my_app.secret_key }
    end
    it { expect(response).to have_http_status(200) }
    it 'manda la lista de pagos del crédito' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(SimCustomerPayment.count)
    end

    it 'manda los datos del pago del crédito' do
      json_array = JSON.parse(response.body)
      @sim_customer_payment = json_array['data'][0]
      expect(@sim_customer_payment['attributes'].keys).to contain_exactly('id', 'pay_number', 'current_debt', 'remaining_debt', 'payment', 'capital', 'interests', 'iva', 'payment_date',
                                                                          'status', 'attached', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at', 'insurance', 'commission',
                                                                          'aditional_payment', 'customer_credit_id')
    end
  end

  describe 'GET /customer_credits/:customer_credit_id/sim_customer_payments/:id' do
    before :each do
      @sim_customer_payment = FactoryBot.create(:sim_customer_payment, customer_credit: @customer_credit)
      get api_v1_customer_credit_sim_customer_payment_path(@customer_credit, @sim_customer_payment),
          params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'el pago del crédito solicitado en JSON' do
      json = JSON.parse(response.body)

      expect(json['data']['attributes']['id']).to eq(@sim_customer_payment.id)
    end
  end

  describe 'POST /customer_credits/:customer_credit_id/sim_customer_payments' do
    context 'con usuario válido' do
      before :each do
        @customer_credit = FactoryBot.create(:customer_credit)
        post api_v1_customer_credit_sim_customer_payments_path(@customer_credit),
             params: { sim_customer_payment: { pay_number: 1, current_debt: '100000.00', remaining_debt: '100000.00', payment: '50000.00', capital: '3000.00', interests: '1500.00',
                                               iva: '500.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_customer_payment.pdf',
                                               customer_credit_id: @customer_credit.id },
                       token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'cambia el número de pagos +1' do
        expect do
          @customer_credit = FactoryBot.create(:customer_credit)
          post api_v1_customer_credit_sim_customer_payments_path(@customer_credit),
               params: { sim_customer_payment: { pay_number: 1, current_debt: '100000.00', remaining_debt: '100000.00', payment: '50000.00', capital: '3000.00', interests: '1500.00',
                                                 iva: '500.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_customer_payment.pdf',
                                                 customer_credit_id: @customer_credit.id },
                         token: @token.token, secret_key: my_app.secret_key }
        end.to change(SimCustomerPayment, :count).by(1)
      end
      it 'responde con el pago creado' do
        json = JSON.parse(response.body)
        # puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> json respond: #{json.inspect}"
        expect(json['data']['attributes']['status']).to eq('AC')
      end
    end

    context 'con usuario inválido' do
      before :each do
        @customer_credit = FactoryBot.create(:customer_credit)
        post api_v1_customer_credit_sim_customer_payments_path(@customer_credit),
             params: { sim_customer_payment: { pay_number: 1, current_debt: '100000.00', remaining_debt: '100000.00', payment: '50000.00', capital: '3000.00', interests: '1500.00',
                                               iva: '500.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_customer_payment.pdf',
                                               customer_credit_id: @customer_credit.id },
                       token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'cambia el número de pagos +0' do
        expect do
          @customer_credit = FactoryBot.create(:customer_credit)
          post api_v1_customer_credit_sim_customer_payments_path(@customer_credit),
               params: { sim_customer_payment: { pay_number: 1, current_debt: '100000.00', remaining_debt: '100000.00', payment: '50000.00', capital: '3000.00', interests: '1500.00',
                                                 iva: '500.00', payment_date: '2021-03-01', status: 'AC', attached: 'http://localhost/sim_customer_payment.pdf',
                                                 customer_credit_id: @customer_credit.id },
                         token: 'sf4fsfd453f34fqgf55gd', secret_key: my_app.secret_key }
        end.to change(SimCustomerPayment, :count).by(0)
      end
    end
  end

  describe 'PUT/PATCH /customer_credit/:customer_credit_id/sim_customer_payments/:id' do
    before :each do
      @sim_customer_payment = FactoryBot.create(:sim_customer_payment, customer_credit: @customer_credit)
      patch api_v1_customer_credit_sim_customer_payment_path(@customer_credit, @sim_customer_payment),
            params: { sim_customer_payment: { status: 'LI' }, token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it ' actualiza los datos indicados ' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes']['status']).to eq('LI')
    end
  end

  describe 'DELETE /customer_credits/:customer_credit_id/sim_customer_payments/:id' do
    before :each do
      @sim_customer_payment = FactoryBot.create(:sim_customer_payment, customer_credit: @customer_credit)
    end

    it 'responde con estatus 200' do
      delete api_v1_customer_credit_sim_customer_payment_path(@customer_credit, @sim_customer_payment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(response).to have_http_status(200)
    end

    it 'elimina el pago' do
      delete api_v1_customer_credit_sim_customer_payment_path(@customer_credit, @sim_customer_payment),
             params: { token: @token.token, secret_key: my_app.secret_key }
      expect(SimCustomerPayment.where(id: @sim_customer_payment.id)).to be_empty
    end

    it 'reduce el conteo de pagos en -1' do
      expect do
        delete api_v1_customer_credit_sim_customer_payment_path(@customer_credit, @sim_customer_payment),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(SimCustomerPayment, :count).by(-1)
    end
  end
end
