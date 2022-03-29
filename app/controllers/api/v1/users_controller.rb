# frozen_string_literal: true

class Api::V1::UsersController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::UsersApi

  before_action :authenticate, except: %i[create update]
  before_action :set_user, only: %i[show update destroy]
  

  def index
    @users = User.all
  end

  def show; end

  # POST /users
  def create
    ActiveRecord::Base.transaction do
      @role = Role.find(user_params[:role_id]) unless user_params[:role_id].nil?
      if @role.nil?
        @user = User.new(user_params)
      else
        @user = @role.users.new(user_params)
      end
      #@reset_password_token = @user.tokens.create(my_app: @my_app)#@current_user.tokens.create(my_app: @my_app)
      #@user.reset_password_token = @reset_password_token.token
      if @user.save
        expires_at ||= 1.day.from_now
        @reset_password_token = @user.tokens.create(my_app: @my_app, expires_at: expires_at)#@current_user.tokens.create(my_app: @my_app)
        #@user.reset_password_token = @reset_password_token.token
        @user.update(reset_password_token: @reset_password_token.token, status: 'SV')
        unless @role.nil?
          @role_options = RoleOption.where(role_id: @role.id)
          unless @role_options.nil?
            create_user_options
          end
        end
        if @mailer_mode == 'TEST'
          @mailer_mail_to = @mailer_test_email
        else
          @mailer_mail_to = @user.email
        end
        @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
        SendMailMailer.send_email(@mailer_mail_to,
                                  @user.name,
                                  "FactorGFC - ¡Bienvenido a nuestro sistema de factoraje!",
                                  "Bienvenido a nuestro sistema de factoraje.",
                                  "tu usuario ya fue dado de alta en el sistema, para crear tu contraseña puedes entrar a la siguiente liga: #{@frontend_url}/#{@reset_password_token.token}. Por motivos de seguridad la liga solo estará vigente 24 horas.").deliver_now
        render 'api/v1/users_reset_password/show'
      else
        render json: { error: @user.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end  
  end

  def update
    if user_params[:status].blank?
       authenticate
      unless @current_user.blank?
        if @user.update(user_params)
          unless user_params[:role_id].nil?
            @role_options = RoleOption.where(role_id: user_params[:role_id])
            unless @role_options.nil?
              create_user_options
            end
          end
          render 'api/v1/users/show'
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    else
      if @user.update(user_params)
        unless user_params[:role_id].nil?
          @role_options = RoleOption.where(role_id: user_params[:role_id])
          unless @role_options.nil?
            create_user_options
          end
        end
        render 'api/v1/users/show'
      else
        render json: @user.errors, status: :unprocessable_entity
      end    
    end    
  end

  def destroy
    @user.destroy
    render json: { message: 'El usuario fue eliminado' }
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:auth).permit(:role_id, :email, :password, :name, :job, :gender, :status)#, :status) #(:email, :password, :name, :role_id) 
  end

  def create_user_options
    @role_options.each do |role_option|
      UserOption.custom_update_or_create(@user.id, role_option.option_id)
    end
  end
end
