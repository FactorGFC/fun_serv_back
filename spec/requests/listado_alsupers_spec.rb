# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::ListadoAlsupersController, listado_alsupers_type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /listado_alsupers' do
    before :each do
      FactoryBot.create_list(:listado_alsuper, 10)
      get '/api/v1/listado_alsupers', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'espera que mande la lista de listado_alsupers' do
      json = JSON.parse(response.body)
      puts json
      expect(json['data'].length).to eq(ListadoAlsuper.count)
    end
  end

  describe 'GET /listado_alsupers/:id' do
    before :each do
      @listado_alsuper = FactoryBot.create(:listado_alsuper)
      get "/api/v1/listado_alsupers/#{@listado_alsuper.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el listado al cliente solicitado' do
      json = JSON.parse(response.body)
      puts json
      expect(json['data']['id']).to eq @listado_alsuper.id
    end

    it 'manda los atributos del LISTADO' do
      json = JSON.parse(response.body)
      puts json
      expect(json['data']['attributes'].keys).to contain_exactly('id','area','banco','curp','cla_area','cla_depto','cla_puesto','cla_trab',
                                                                'clabe','departamento','noafiliacion','nombre','primer_apellido','puesto','rfc',
                                                                'segundo_apellido','tarjeta','tipo_puesto','fecha_ingreso','customer_id','created_at', 'updated_at')
    end
  end

  describe 'POST /listado_alsupers' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        
        @customer =FactoryBot.create(:customer)

        post '/api/v1/listado_alsupers', params: { token: @token.token, secret_key: @my_app.secret_key, listado_alsuper: {nombre:  'Pedro',
                                                   primer_apellido: 'Paramo',segundo_apellido:  'Paramo',banco: 'Global',
                                                   clabe:  '123456789987654321',cla_trab:  '123456' ,cla_depto: '123456',
                                                   departamento:  'Empleado',cla_area: '123456' ,area: 'Trabajadores',
                                                   cla_puesto: '123456',puesto:  'Empleado' ,noafiliacion:  '123456',
                                                   rfc:  'ABCD123456GH45IO5',curp:  'ABCD123456GH457',tarjeta:  '123456',
                                                   tipo_puesto:  'Empleado 1',fecha_ingreso: '29-Sep-88', customer_id: @customer.id}
                                                   }
      end
      it { expect(response).to have_http_status(200) }

      it 'crea un nuevo registro del listado de alsuper' do
        expect do
          post '/api/v1/listado_alsupers', params: { token: @token.token, secret_key: @my_app.secret_key, listado_alsuper: {nombre:  'Pedro',
                                                            primer_apellido: 'Paramo',segundo_apellido:  'Paramo',banco: 'Global',
                                                            clabe:  '123456789987654321',cla_trab:  '123456' ,cla_depto: '123456',
                                                            departamento:  'Empleado',cla_area: '123456' ,area: 'Trabajadores',
                                                            cla_puesto: '123456',puesto:  'Empleado' ,noafiliacion:  '123456',
                                                            rfc:  'ABCD123456GH45IO5',curp:  'ABCD123456GH457',tarjeta:  '123456',
                                                            tipo_puesto:  'Empleado 1',fecha_ingreso: '29-Sep-88', customer_id: @customer.id}
                                                            }
        end.to change(ListadoAlsuper, :count).by(1)
      end
      it 'responde con el registro creado' do
        json = JSON.parse(response.body)
        puts "11111111111111111>>>>>>>>>>>>>>>>>>>>>>>>#{json.inspect}"
        expect(json['data']['attributes']['rfc']).to eq('ABCD123456GH45IO5')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/listado_alsupers', params: { 
          secret_key: my_app.secret_key
       }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        # @listado_alsuper = FactoryBot.create(:listado_alsuper)
        @customer =FactoryBot.create(:customer)

        post '/api/v1/listado_alsupers', params: { token: @token.token, secret_key: @my_app.secret_key, listado_alsuper: {nombre:  'Pedro',
                                                    primer_apellido: 'Paramo',segundo_apellido:  'Paramo',banco: 'Global',
                                                    clabe:  '123456789987654321',cla_trab:  '123456' ,cla_depto: '123456',
                                                    departamento:  'Empleado',cla_area: '123456' ,area: 'Trabajadores',
                                                    cla_puesto: '123456',puesto:  'Empleado' ,noafiliacion:  '123456',
                                                    rfc:  'ABCD123456GH45IO5',curp:  'ABCD123456GH457',tarjeta:  '123456',
                                                    tipo_puesto:  'Empleado 1',fecha_ingreso: '29-Sep-88', customer_id: @customer.id}
                                                    } 
      end
      it { expect(response).to have_http_status(401) }

      it 'responde con los errores al guardar el registro' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end

  end   
  
  describe 'PATCH /listado_alsupers/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @listado_alsuper = FactoryBot.create(:listado_alsuper)
        patch api_v1_listado_alsuper_path(@listado_alsuper), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                                       listado_alsuper: { departamento:  'Contabilidad' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el registro' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['departamento']).to eq('Contabilidad')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @listado_alsuper = FactoryBot.create(:listado_alsuper)
        patch api_v1_listado_alsuper_path(@listado_alsuper), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                       listado_alsuper: { departamento: 'Compras' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /listado_alsupers' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
          @listado_alsuper = FactoryBot.create(:listado_alsuper)
      end
      it {
        delete api_v1_listado_alsuper_path(@listado_alsuper), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el credito al cliente indicado' do
        expect do
          delete api_v1_listado_alsuper_path(@listado_alsuper), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(ListadoAlsuper, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
                                   @listado_alsuper = FactoryBot.create(:listado_alsuper)
        delete api_v1_listado_alsuper_path(@listado_alsuper),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

end