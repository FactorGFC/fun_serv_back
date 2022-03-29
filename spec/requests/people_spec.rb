# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot'

RSpec.describe Api::V1::PeopleController, type: :request do
  let(:user) { FactoryBot.create(:sequence_user) }
  let(:my_app) { FactoryBot.create(:my_app, user: user) }
  let(:token) { FactoryBot.create(:token, user: user, my_app: my_app) }

  describe 'GET /people' do
    before :each do
      FactoryBot.create_list(:person, 10)
      get '/api/v1/people', params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de personas físicas' do
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(Person.count)
    end
  end

  describe 'GET /people/:id' do
    before :each do
      @person = FactoryBot.create(:person)
      get "/api/v1/people/#{@person.id}", params: { token: token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda la persona física solicitada' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @person.id
    end

    it 'manda los atributos de la persona física' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'fiscal_regime', 'rfc', 'curp', 'imss', 'first_name',
                                                                 'last_name', 'second_last_name', 'gender', 'nationality',
                                                                 'birth_country', 'birthplace', 'birthdate', 'martial_status',
                                                                 'id_type', 'identification', 'phone', 'mobile', 'email',
                                                                 'fiel', 'extra1', 'extra2', 'extra3', 'created_at', 'updated_at')
    end
  end

  describe 'POST /people' do
    context 'con token válido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/people', params: { token: @token.token, secret_key: @my_app.secret_key, person: {
          fiscal_regime: 'Persona física', rfc: 'AAAA999999AAA', curp: '99999999AAAEEA', imss: 123_456_789,
          first_name: 'Juan', last_name: 'Perez', second_last_name: 'Perez', gender: 'Masculino',
          nationality: 'Mexicano', birth_country: 'Chihuahua', birthplace: 'Adolfo López',
          birthdate: '1984-10-10', martial_status: 'Soltero', id_type: 'INE', identification: 123_456_789,
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
      it { expect(response).to have_http_status(200) }
      it 'crea una nueva persona física' do
        expect do
          post '/api/v1/people', params: { token: @token.token, secret_key: @my_app.secret_key, person: {
            fiscal_regime: 'Persona física', rfc: 'AAAA999999AAB', curp: '99999999AAAEEA', imss: 123_456_789,
            first_name: 'Juan', last_name: 'Perez', second_last_name: 'Perez', gender: 'Masculino',
            nationality: 'Mexicano', birth_country: 'Chihuahua', birthplace: 'Adolfo López',
            birthdate: '1984-10-10', martial_status: 'Soltero', id_type: 'INE', identification: 123_456_789,
            phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', fiel: false, extra1: 'valor1',
            extra2: 'valor2', extra3: 'valor3'
          } }
        end.to change(Person, :count).by(1)
      end
      it 'responde con la cadena creada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['rfc']).to eq('AAAA999999AAA')
      end
    end

    context 'con token invalido' do
      before :each do
        post '/api/v1/people', params: { secret_key: my_app.secret_key, person: {
          fiscal_regime: 'Persona física', rfc: 'AAAA999999AAA', curp: '99999999AAAEEA', imss: 123_456_789,
          first_name: 'Juan', last_name: 'Perez', second_last_name: 'Perez', gender: 'Masculino',
          nationality: 'Mexicano', birth_country: 'Chihuahua', birthplace: 'Adolfo López',
          birthdate: DateTime.now.strftime('%m/%d/%Y'), martial_status: 'Soltero', id_type: 'INE', identification: 123_456_789,
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
      it { expect(response).to have_http_status(401) }
    end

    context 'con token vencido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now - 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/people', params: { token: @token.token, secret_key: @my_app.secret_key, person: {
          fiscal_regime: 'Persona física', rfc: 'AAAA999999AAA', curp: '99999999AAAEEA', imss: 123_456_789,
          first_name: 'Juan', last_name: 'Perez', second_last_name: 'Perez', gender: 'Masculino',
          nationality: 'Mexicano', birth_country: 'Chihuahua', birthplace: 'Adolfo López',
          birthdate: DateTime.now.strftime('%m/%d/%Y'), martial_status: 'Soltero', id_type: 'INE', identification: 123_456_789,
          phone: '999999999999', mobile: '999999999999', email: 'mail@mail.com', fiel: false, extra1: 'valor1',
          extra2: 'valor2', extra3: 'valor3'
        } }
      end
    end

    context 'parametros invalidos' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        post '/api/v1/people', params: { token: @token.token, secret_key: @my_app.secret_key, person: {
          fiscal_regime: 'Persona física'
        } }
      end

      it { expect(response).to have_http_status(422) }

      it 'responde con los errores al guardar la persona física' do
        json = JSON.parse(response.body)
        expect(json['errors']).to_not be_empty
      end
    end
  end
  describe 'PATCH /people/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @person = FactoryBot.create(:person)
        patch api_v1_person_path(@person), params: { token: @token.token, secret_key: @my_app.secret_key,
                                                                         person: { first_name: 'Pedro' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza la persona física indicada' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['first_name']).to eq('Pedro')
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @person = FactoryBot.create(:person)
        patch api_v1_person_path(@person), params: { token: @token.token, secret_key: my_app.secret_key,
                                                                         person: { first_name: 'Pedro' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /people' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @person = FactoryBot.create(:person)
      end
      it {
        delete api_v1_person_path(@person), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina la persona física indicada' do
        expect do
          delete api_v1_person_path(@person), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(Person, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token,
                                   expires_at: DateTime.now + 10.minutes, user: @user, my_app: @my_app)
        @person = FactoryBot.create(:person)
        delete api_v1_person_path(@person),
               params: { secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end
