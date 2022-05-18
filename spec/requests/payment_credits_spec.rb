# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::PaymentCreditsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }

  before :each do
    @token = FactoryBot.create(:token, user: user, my_app: my_app)
    @contributor_finan = FactoryBot.create(:contributor)
    @contributor_supplier = FactoryBot.create(:contributor_pf)
    @payment = FactoryBot.create(:payment, contributor_from: @contributor_finan, contributor_to: @contributor_supplier)
    #invoice
    @contributor_to_cp = FactoryBot.create(:contributor_pm)
    @company = FactoryBot.create(:company, contributor: @contributor_to_cp)
    @customer = FactoryBot.create(:customer, company: @company, contributor: @contributor_supplier)

   # @suppler_segment = FactoryBot.create(:supplier_segment, company: @company, supplier: @supplier)
   # @invoice = FactoryBot.create(:invoice, company: @company, supplier: @supplier)
   @customer_credit = FactoryBot.create(:customer_credit, customer: @customer)
    @payment_credit = FactoryBot.create(:payment_credit, payment: @payment, customer_credit: @customer_credit)
  end

  describe 'POST /payment_credits' do
    before :each do
      post api_v1_payment_credits_path,
           params: { payment_id: @payment.id, customer_credit_id: @customer_credit.id, pc_type: 'PROVEEDOR', total: '10000',
                     token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'responde con el nuevo payment invoice' do
      json = JSON.parse(response.body)
      # puts "\n\n #{json} \n\n"
      expect(json['data']['id']).to eq(PaymentCredit.last.id)
    end

    context 'con usuario inválido' do
      before :each do
        post api_v1_payment_credits_path,
        params: { payment_id: @payment.id, customer_credit_id: @customer_credit.id, pc_type: 'PROVEEDOR', total: '10000',
                       token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de pagos de creditos' do
        expect do
          post api_v1_payment_credits_path,
          params: { payment_id: @payment.id, customer_credit_id: @customer_credit.id, pc_type: 'PROVEEDOR', total: '10000',
                         token: 'dfsfsdfasdfsdf', secret_key: my_app.secret_key }
        end .to change(PaymentCredit, :count).by(0)
      end
    end

    context 'con token vencido' do
      before :each do
        # new_user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: user, my_app: my_app)
        post api_v1_payment_credits_path,
        params: { payment_id: @payment.id, customer_credit_id: @customer_credit.id, pc_type: 'PROVEEDOR', total: '10000',
          token: @token.token, secret_key: my_app.secret_key }
      end

      it { expect(response).to have_http_status(401) }
      it 'no cambio el número de detalles de pagos de creditos' do
        expect do
          post api_v1_payment_credits_path,
          params: { payment_id: @payment.id, customer_credit_id: @customer_credit.id, pc_type: 'PROVEEDOR', total: '10000',
            token: @token.token, secret_key: my_app.secret_key }
        end .to change(RoleOption, :count).by(0)
      end
    end
  end

  describe 'delete /payment_credits' do
    before :each do
      @contributor_finan = FactoryBot.create(:contributor)
      @contributor_supplier = FactoryBot.create(:contributor_pf)
      @payment = FactoryBot.create(:payment, contributor_from: @contributor_finan, contributor_to: @contributor_supplier)
      #invoice
      @contributor_to_cp = FactoryBot.create(:contributor_pm)
      @company = FactoryBot.create(:company, contributor: @contributor_to_cp)
      @customer = FactoryBot.create(:customer, contributor: @contributor_supplier)

    #  @suppler_segment = FactoryBot.create(:supplier_segment, company: @company, supplier: @supplier)
     # @invoice = FactoryBot.create(:invoice, company: @company, supplier: @supplier)
     @customer_credit = FactoryBot.create(:customer_credit,  customer: @customer)
      @payment_credit2 = FactoryBot.create(:payment_credit, payment: @payment, customer_credit: @customer_credit)
      delete api_v1_payment_credit_path(@payment_credit),
               params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'elimina el detalle de pago del credito' do
      expect do
        delete api_v1_payment_credit_path(@payment_credit2),
               params: { token: @token.token, secret_key: my_app.secret_key }
      end.to change(PaymentCredit, :count).by(-1)
    end
  end
end
