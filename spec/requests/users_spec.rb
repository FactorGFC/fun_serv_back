# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:my_app) do
    FactoryBot.create(:my_app, user: FactoryBot.create(:sequence_user))
  end

  describe 'GET /users' do
    before :each do
      FactoryBot.create_list(:sequence_user, 10)
      @user = FactoryBot.create(:sequence_user)
      @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
      get '/api/v1/users', params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }
    it 'mande la lista de usuarios' do
      # puts "\n\n #{response.body} \n\n"
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(User.count)
    end
  end

  describe 'GET /users/:id' do
    before :each do
      @user = FactoryBot.create(:sequence_user)
      @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
      get "/api/v1/users/#{@user.id}", params: { token: @token.token, secret_key: my_app.secret_key }
    end

    it { expect(response).to have_http_status(200) }

    it 'manda el usuario solicitado' do
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq @user.id
    end

    it 'manda los atributos del usuario' do
      json = JSON.parse(response.body)
      expect(json['data']['attributes'].keys).to contain_exactly('id', 'role_id', 'email', 'name', 'job', 'gender', 'status', 'password_digest', 'reset_password_token', 'created_at', 'updated_at')
    end
  end

  describe 'POST /users' do
    context 'User sin rol' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
        auth = { email: 'c@mail.com', password: '123456789', name: 'eloy' }
        post api_v1_users_path,
             params: { auth: auth, token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      
      it 'Crea un nuevo usuario' do
        expect do
          auth = { email: 'c2@mail.com', password: '123456789', name: 'eloy' }
          post api_v1_users_path,
               params: { auth: auth, token: @token.token, secret_key: my_app.secret_key }
        end.to change(User, :count).by(1)
      end

      it 'responde con el usuario encontrado o creado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['email']).to eq('c@mail.com')
      end
    end

    context 'POST /users con rol sin role options' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
        @role = FactoryBot.create(:role)
        auth = { email: 'c@mail.com', password: '123456789', name: 'eloy', role_id: @role.id }
        post api_v1_users_path,
             params: { auth: auth, token: @token.token, secret_key: my_app.secret_key }
      end
      it { expect(response).to have_http_status(200) }
      it 'Crea un nuevo usuario' do
        expect do
          auth = { email: 'c3@mail.com', password: '123456789', name: 'eloy', role_id: @role.id }
          post api_v1_users_path,
               params: { auth: auth, token: @token.token, secret_key: my_app.secret_key }
        end.to change(User, :count).by(1)
      end
  
      it 'responde con el usuario encontrado o creado' do
        json = JSON.parse(response.body)
        # puts "\n\n #{json} \n\n"
        expect(json['data']['attributes']['email']).to eq('c@mail.com')
      end
    end

    context 'POST /users con rol con role options' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
        @role = FactoryBot.create(:role)
        10.times do
          @option = FactoryBot.create(:sequence_option)
          @role_option = FactoryBot.create(:role_option_sf, role: @role, option: @option)
        end
        auth = { email: 'c@mail.com', password: '123456789', name: 'eloy', role_id: @role.id }
        post api_v1_users_path,
             params: { auth: auth, token: @token.token, secret_key: my_app.secret_key }
      end
      it 'responde con las opciones del usuario creadas' do
        json = JSON.parse(response.body)
        expect(json['data']['relations']['options']).not_to be_empty
      end
    end
  end

  describe 'PATCH /users/:id' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
        patch api_v1_user_path(@user), params: { token: @token.token, secret_key: my_app.secret_key, auth: { name: 'Otro nombre' } }
      end
      it { expect(response).to have_http_status(200) }

      it 'actualiza el usuario indicado' do
        json = JSON.parse(response.body)
        expect(json['data']['attributes']['name']).to eq('Otro nombre')
      end
    end
    
    context 'con rol con opciones' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: @user, my_app: my_app)
        @role = FactoryBot.create(:role)
        10.times do
          @option = FactoryBot.create(:sequence_option)
          @role_option = FactoryBot.create(:role_option_sf, role: @role, option: @option)
        end
        patch api_v1_user_path(@user), params: { token: @token.token, secret_key: my_app.secret_key, auth: { role_id: @role.id } }
      end
      it { expect(response).to have_http_status(200) }

      it 'responde con las opciones del usuario creadas' do
        json = JSON.parse(response.body)
        expect(json['data']['relations']['options']).not_to be_empty
      end
    end

    context 'con un token invalido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user), my_app: @my_app)
        patch api_v1_user_path(@user), params: { token: @token.token, secret_key: my_app.secret_key,
                                                 auth: { title: 'Otro nombre' } }
      end
      it { expect(response).to have_http_status(401) }
    end
  end

  describe 'DELETE /users' do
    context 'con un token valido' do
      before :each do
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        @token = FactoryBot.create(:token, expires_at:
          DateTime.now + 10.minutes, user: @user, my_app: @my_app)
      end
      it {
        delete api_v1_user_path(@user), params:
          { token: @token.token, secret_key: @my_app.secret_key }
        expect(response).to have_http_status(200)
      }

      it 'elimina el usuario indicado' do
        expect do
          delete api_v1_user_path(@user), params:
            { token: @token.token, secret_key: @my_app.secret_key }
        end.to change(User, :count).by(-1)
      end
    end
    context 'con un token invalido' do
      before :each do
        @token = FactoryBot.create(:token, 
                                   expires_at: DateTime.now + 10.minutes, user: FactoryBot.create(:sequence_user))
        @user = FactoryBot.create(:sequence_user)
        @my_app = FactoryBot.create(:my_app, user: @user)
        delete api_v1_user_path(@user),
               params: { token: @token.token, secret_key: @my_app.secret_key }
      end
      it { expect(response).to have_http_status(401) }
    end
  end
end


