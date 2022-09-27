require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::CreditAnalysesController, credit_analysis_type: :request do
    let(:user) { FactoryBot.create(:sequence_user) }
    let(:my_app) { FactoryBot.create(:my_app, user: user) }
    let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

    describe 'GET /credit_analyses' do
        before :each do
          FactoryBot.create_list(:credit_analysis, 10)
          get '/api/v1/credit_analyses', params: { token: token.token, secret_key: my_app.secret_key }
        end
        
        it { expect(response).to have_http_status(200) }
        it 'mande la lista de credito al analista' do
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(CreditAnalysis.count)
        end
    end

    describe 'GET /credit_analyses/:id' do
      before :each do
        @credit_analysis = FactoryBot.create(:credit_analysis)
        get "/api/v1/credit_analyses/#{@credit_analysis.id}", params: { token: token.token, secret_key: my_app.secret_key }
      end
  
      it { expect(response).to have_http_status(200) }

  
      it 'manda el analisys al cliente solicitado' do
        json = JSON.parse(response.body)
        expect(json['data']['id']).to eq @credit_analysis.id
      end
  
      it 'manda los atributos del analisis de credito al cliente' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes'].keys).to contain_exactly('id', 'debt_rate', 'cash_flow', 'credit_status', 'previus_credit', 'discounts', 'debt_horizon',
                                                                   'report_date', 'mop_key', 'last_key', 'balance_due', 'payment_capacity', 'lowest_key', 'departamental_credit',
                                                                    'car_credit', 'mortagage_loan', 'other_credits', 'accured_liabilities', 'debt', 'net_flow', 'customer_credit_id',
                                                                    'created_at', 'updated_at', 'anual_rate', 'credit_type', 'customer_number', 'overall_rate', 'total_amount', 'total_cost', 'total_debt' 
                                                                  )
      end
    end

    describe 'POST /credit_analyses' do
      context 'con token válido' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
          @credit_analysis = FactoryBot.create(:credit_analysis)
          @customer_credit =FactoryBot.create(:customer_credit)

          post '/api/v1/credit_analyses', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                    credit_analysis: {  debt_rate: '8.45', cash_flow:'100.53', credit_status: 'Bueno', 
                                                    previus_credit: 'NO', discount: '20', debt_horizon: ' 3.0', report_date: '2022-05-01', 
                                                    mop_key: 'NO', last_key: '1', balance_due: 'NO', payment_capacity: '65.29', lowest_key: '1',
                                                    accured_liabilities: '11145.00', net_flow: '2867.25', customer_credit_id: @customer_credit.id} }
        end
        it { expect(response).to have_http_status(200) }
  
        it 'crea un nuevo analisis de credito' do
          expect do
            post '/api/v1/credit_analyses', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                       credit_analysis: { debt_rate: '8.45', cash_flow:'100.53', credit_status: 'Bueno', 
                                                       previus_credit: 'NO', discount: '20', debt_horizon: ' 3.0', report_date: '2022-05-01', 
                                                       mop_key: 'NO', last_key: '1', balance_due: 'NO', payment_capacity: '65.29', lowest_key: '1',
                                                       accured_liabilities: '11145.00', net_flow: '2867.25', customer_credit_id: @customer_credit.id } }
          end.to change(CreditAnalysis, :count).by(1)
        end
        it 'responde con la cadena creada' do
          json = JSON.parse(response.body)
          expect(json['data']['attributes']['credit_status']).to eq('Bueno')
        end
      end
  
      context 'con token invalido' do
        before :each do
          post '/api/v1/credit_analyses', params: { secret_key: my_app.secret_key }
        end
        it { expect(response).to have_http_status(401) }
      end
  
      context 'con token vencido' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
          @credit_analysis = FactoryBot.create(:credit_analysis)
          @customer_credit =FactoryBot.create(:customer_credit)
  
          post '/api/v1/credit_analyses', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                    credit_analysis: { debt_rate: '8.45', cash_flow:'100.53', credit_status: 'Bueno', 
                                                    previus_credit: 'NO', discount: '20', debt_horizon: ' 3.0', report_date: '2022-05-01', 
                                                    mop_key: 'NO', last_key: '1', balance_due: 'NO', payment_capacity: '65.29', lowest_key: '1',
                                                    accured_liabilities: '11145.00', net_flow: '2867.25', customer_credit_id: @customer_credit.id } }
        end
        it { expect(response).to have_http_status(401) }
  
        it 'responde con los errores al guardar el analisis del credito' do
          json = JSON.parse(response.body)
          expect(json['errors']).to_not be_empty
        end
      end
  
      context 'parametros invalidos' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
          @credit_analysis = FactoryBot.create(:credit_analysis)
          @customer_credit =FactoryBot.create(:customer_credit)
  
          post '/api/v1/credit_analyses', params: { token: @token.token, secret_key: @my_app.secret_key,
                                                     credit_analysis: { cash_flow:'100.53', credit_status: 'Bueno', 
                                                     previus_credit: 'NO', discount: '20', debt_horizon: ' 3.0', report_date: '2022-05-01', 
                                                     last_key: '1', balance_due: 'NO', payment_capacity: '65.29', lowest_key: '1',
                                                     accured_liabilities: '11145.00', net_flow: '2867.25'} }
        end
  
        it { expect(response).to have_http_status(422) }

        it 'responde con los errores al guardar el credito al cliente' do
          json = JSON.parse(response.body)
          #puts ">>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
          expect(json['error']).to_not be_empty
        end
  
      end
    end   

    describe 'PATCH /credit_analyses/:id' do
      context 'con un token valido' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
          @credit_analysis = FactoryBot.create(:credit_analysis)
          patch api_v1_credit_analysis_path(@credit_analysis), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                                         credit_analysis: { credit_status: 'Malo' } }
        end
        it { expect(response).to have_http_status(200) }
  
        it 'actualiza el analisis al credito indicado' do
          json = JSON.parse(response.body)
          expect(json['data']['attributes']['credit_status']).to eq('Malo')
        end
      end
      context 'con un token invalido' do
        before :each do
          @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
          @credit_analysis = FactoryBot.create(:credit_analysis)
          patch api_v1_credit_analysis_path(@credit_analysis), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                         credit_analysis: { credit_status: 'Malo' } }
        end
        it { expect(response).to have_http_status(401) }
      end
    end

    describe 'DELETE /credit_analyses' do
      context 'con un token valido' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token, expires_at:
            DateTime.now + 10.minutes, user: @user, my_app: @my_app)
            @credit_analysis = FactoryBot.create(:credit_analysis)
        end
        it {
          delete api_v1_credit_analysis_path(@credit_analysis), params:
            { token: @token.token, secret_key: @my_app.secret_key }
          expect(response).to have_http_status(200)
        }
  
        it 'elimina el credito al cliente indicado' do
          expect do
            delete api_v1_credit_analysis_path(@credit_analysis), params:
              { token: @token.token, secret_key: @my_app.secret_key }
          end.to change(CreditAnalysis, :count).by(-1)
        end
      end
      context 'con un token invalido' do
        before :each do
          @user = FactoryBot.create(:sequence_user)
          @my_app = FactoryBot.create(:my_app, user: @user)
          @token = FactoryBot.create(:token,
                                     expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
                                     @credit_analysis = FactoryBot.create(:credit_analysis)
          delete api_v1_credit_analysis_path(@credit_analysis),
                 params: { secret_key: @my_app.secret_key }
        end
        it { expect(response).to have_http_status(401) }
      end
    end
end
