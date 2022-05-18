# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::PaymentsController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /payments' do
    before :each do
      @contributor_from = FactoryBot.create(:contributor)
      @contributor_to = FactoryBot.create(:contributor)
      FactoryBot.create_list(:payment, 10, contributor_from: @contributor_from, contributor_to: @contributor_to)
      get '/api/v1/payments', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de pagos' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Payment.count)
    end
  end

  describe 'GET /payments/:id' do
    before :each do
      @contributor_from = FactoryBot.create(:contributor)
      @contributor_to = FactoryBot.create(:contributor)
      @payment = FactoryBot.create(:payment, contributor_from: @contributor_from, contributor_to: @contributor_to)
      get "/api/v1/payments/#{@payment.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el pago solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @payment.id
    end

    it 'manda los atributos del pago' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'payment_date', 'payment_type', 'payment_number', 'currency', 'amount', 'email_cfdi', 'notes', 'voucher', 'contributor_from_id', 'contributor_to_id', 'created_at', 'updated_at')
    end
  end

  describe 'POST /payments' do
    context 'con facturacion pago a proveedor y luego a cadena sin solicitud' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity, fiscal_regime: 'PERSONA MORAL', rfc: 'FGG120928632', business_name: 'FACTOR GFC GLOBAL SA DE CV SOFOM ENR', business_email: 'eloyra@gmail.com', extra1: 'e9aT1ajrRh1NyRkzOtDoN1ZEGmIsEKuJ6f3FYyLh', extra2: '925fa49b0ec6fbab7175574a460d585a', extra3:'Basic RkdHMTIwOTI4NjMyOjkyNWZhNDliMGVjNmZiYWI3MTc1NTc0YTQ2MGQ1ODVh')
        @contributor_from = FactoryBot.create(:contributor_finan, legal_entity: @legal_entity)
        #@contributor_to = FactoryBot.create(:contributor)
        # se crean las facturas a pagar
        @contributor_from_sp = FactoryBot.create(:contributor)
        @person = FactoryBot.create(:person, fiscal_regime: 'PERSONA FÍSICA', rfc: 'AAA010101AAA', email: 'eloyra@gmail.com', extra1: '7aa16d2e055554fcf3d182758db23c91', extra2: '7aa16d2e055554fcf3d182758db23c91', extra3:'Basic QUFBMDEwMTAxQUFBOjdhYTE2ZDJlMDU1NTU0ZmNmM2QxODI3NThkYjIzYzkx')
        @contributor_to_sp = FactoryBot.create(:contributor_pf, person: @person)
        @customer = FactoryBot.create(:customer, contributor: @contributor_to_sp)
        @contributor_from_cp = FactoryBot.create(:contributor)
        @contributor_to_cp = FactoryBot.create(:contributor_pm)
        @company = FactoryBot.create(:company, contributor: @contributor_to_cp)
        ### falta agregar rfc a ver donde lo debe de llevar
        @customer_credit = FactoryBot.create(:customer_credit)
        ##emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0127a0-75dd-11ea-bd1c-23812db3bda9")  
        @total_requested = @customer_credit.total_requested
        post '/api/v1/payments', params: { token: @token.token, secret_key: @my_app.secret_key, credit_id: @customer_credit.id,
                                           payment: { payment_date: '2020-01-01', payment_type: 'Transferencia', payment_number: 'TR123456789', currency: 'PESOS',
                                                      amount: @total_requested, email_cfdi: 'email@mail.com', notes: 'Trasferencia de la cadena', voucher: 'https://ruta',
                                                      contributor_from_id: @contributor_from.id, contributor_to_id: @contributor_to_sp.id } }      
        end
      it { expect(response).to have_http_status(200) }

    end

    context 'con token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity, fiscal_regime: 'PERSONA MORAL', rfc: 'FGG120928632', business_name: 'FACTOR GFC GLOBAL SA DE CV SOFOM ENR', business_email: 'eloyra@gmail.com', extra1: 'e9aT1ajrRh1NyRkzOtDoN1ZEGmIsEKuJ6f3FYyLh', extra2: '925fa49b0ec6fbab7175574a460d585a', extra3:'Basic RkdHMTIwOTI4NjMyOjkyNWZhNDliMGVjNmZiYWI3MTc1NTc0YTQ2MGQ1ODVh')
        @contributor_from = FactoryBot.create(:contributor_finan, legal_entity: @legal_entity)
        #@contributor_to = FactoryBot.create(:contributor)
        # se crean las facturas a pagar
        @contributor_from_sp = FactoryBot.create(:contributor)
        @person = FactoryBot.create(:person, fiscal_regime: 'PERSONA FÍSICA', rfc: 'AAA010101AAA', email: 'eloyra@gmail.com', extra1: '7aa16d2e055554fcf3d182758db23c91', extra2: '7aa16d2e055554fcf3d182758db23c91', extra3:'Basic QUFBMDEwMTAxQUFBOjdhYTE2ZDJlMDU1NTU0ZmNmM2QxODI3NThkYjIzYzkx')
        @contributor_to_sp = FactoryBot.create(:contributor_pf, person: @person)
        @customer = FactoryBot.create(:customer, contributor: @contributor_to_sp)
        @contributor_from_cp = FactoryBot.create(:contributor)
        @contributor_to_cp = FactoryBot.create(:contributor_pm)
        @company = FactoryBot.create(:company, contributor: @contributor_to_cp)
        #@suppler_segment = FactoryBot.create(:supplier_segment, company: @company, supplier: @supplier)        
        # se crea la solicitud
   
      #  @invoice1 = FactoryBot.create(:invoice, company: @company, supplier: @supplier, emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0127a0-75dd-11ea-bd1c-23812db3bda9")
       # @invoice2 = FactoryBot.create(:invoice, company: @company, supplier: @supplier, emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0137a0-75dd-11ea-bd1c-23812db3bda9")
       # @total_facturas = @invoice1.total + @invoice2.total
### falta agregar rfc a ver donde lo debe de llevar
        @credit = FactoryBot.create(:customer_credit, customer: @customer)
        ##emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0127a0-75dd-11ea-bd1c-23812db3bda9")  
        @total_requested = @credit.total_requested
        post '/api/v1/payments', params: { token: '67579djasbdlsd7687eqd', secret_key: @my_app.secret_key, credit: @credit.id,
                                           payment: { payment_date: '2020-01-01', payment_type: 'Transferencia', payment_number: 'TR123456789', currency: 'PESOS',
                                                      amount: @total_requested, email_cfdi: 'email@mail.com', notes: 'Trasferencia de la cadena', voucher: 'https://ruta',
                                                      contributor_from_id: @contributor_from.id, contributor_to_id: @contributor_to_sp.id } }      
        end
      it { expect(response).to have_http_status(401) }
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @legal_entity = FactoryBot.create(:legal_entity, fiscal_regime: 'PERSONA MORAL', rfc: 'FGG120928632', business_name: 'FACTOR GFC GLOBAL SA DE CV SOFOM ENR', business_email: 'eloyra@gmail.com', extra1: 'e9aT1ajrRh1NyRkzOtDoN1ZEGmIsEKuJ6f3FYyLh', extra2: '925fa49b0ec6fbab7175574a460d585a', extra3:'Basic RkdHMTIwOTI4NjMyOjkyNWZhNDliMGVjNmZiYWI3MTc1NTc0YTQ2MGQ1ODVh')
        @contributor_from = FactoryBot.create(:contributor_finan, legal_entity: @legal_entity)
        #@contributor_to = FactoryBot.create(:contributor)
        # se crean las facturas a pagar
        @contributor_from_sp = FactoryBot.create(:contributor)
        @person = FactoryBot.create(:person, fiscal_regime: 'PERSONA FÍSICA', rfc: 'AAA010101AAA', email: 'eloyra@gmail.com', extra1: '7aa16d2e055554fcf3d182758db23c91', extra2: '7aa16d2e055554fcf3d182758db23c91', extra3:'Basic QUFBMDEwMTAxQUFBOjdhYTE2ZDJlMDU1NTU0ZmNmM2QxODI3NThkYjIzYzkx')
        @contributor_to_sp = FactoryBot.create(:contributor_pf, person: @person)
        @customer = FactoryBot.create(:customer, contributor: @contributor_to_sp)
        @contributor_from_cp = FactoryBot.create(:contributor)
        @contributor_to_cp = FactoryBot.create(:contributor_pm)
        @company = FactoryBot.create(:company, contributor: @contributor_to_cp)
        #@suppler_segment = FactoryBot.create(:supplier_segment, company: @company, supplier: @supplier)        
        # se crea la solicitud
   
      #  @invoice1 = FactoryBot.create(:invoice, company: @company, supplier: @supplier, emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0127a0-75dd-11ea-bd1c-23812db3bda9")
       # @invoice2 = FactoryBot.create(:invoice, company: @company, supplier: @supplier, emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0137a0-75dd-11ea-bd1c-23812db3bda9")
       # @total_facturas = @invoice1.total + @invoice2.total
### falta agregar rfc a ver donde lo debe de llevar
        @customer_credit = FactoryBot.create(:customer_credit)
        ##emitter_rfc: @contributor_to_sp.person.rfc, receiver_rfc: @contributor_to_cp.legal_entity.rfc, uuid: "ce0127a0-75dd-11ea-bd1c-23812db3bda9")  
       
        post '/api/v1/payments', params: { token: @token.token, secret_key: @my_app.secret_key, customer_credit: @customer_credit.id,
                                           payment: { payment_date: '2020-01-01'} }      
        end

      it { expect(response).to have_http_status(422) }
      it 'responde con los errores al guardar el pago' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /payments/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor_from = FactoryBot.create(:contributor)
        @contributor_to = FactoryBot.create(:contributor)
        @payment = FactoryBot.create(:payment, contributor_from: @contributor_from, contributor_to: @contributor_to)
        patch api_v1_payment_path(@payment), params: { token: @token.token, secret_key: @my_app.secret_key, payment: { notes: 'Transferencia del proveedor' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el pago indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['notes']).to eq('Transferencia del proveedor')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @contributor_from = FactoryBot.create(:contributor)
        @contributor_to = FactoryBot.create(:contributor)
        @payment = FactoryBot.create(:payment, contributor_from: @contributor_from, contributor_to: @contributor_to)
        patch api_v1_payment_path(@payment), params: { token: @token.token, secret_key: my_app.secret_key,
                                                       payment: { name: 'Administrador2' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /payments' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor_from = FactoryBot.create(:contributor)
        @contributor_to = FactoryBot.create(:contributor)
        @payment = FactoryBot.create(:payment, contributor_from: @contributor_from, contributor_to: @contributor_to)
      end
      it {
        delete api_v1_payment_path(@payment), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el pago indicado' do
        expect do
          delete api_v1_payment_path(@payment), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Payment, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @contributor_from = FactoryBot.create(:contributor)
        @contributor_to = FactoryBot.create(:contributor)
        @payment = FactoryBot.create(:payment, contributor_from: @contributor_from, contributor_to: @contributor_to)
        delete api_v1_payment_path(@payment),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
