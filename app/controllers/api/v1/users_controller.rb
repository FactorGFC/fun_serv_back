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
      @user = if @role.nil?
                User.new(user_params)
              else
                @role.users.new(user_params)
              end
      # @reset_password_token = @user.tokens.create(my_app: @my_app)#@current_user.tokens.create(my_app: @my_app)
      # @user.reset_password_token = @reset_password_token.token
      if @user.save
        expires_at ||= 1.day.from_now
        @reset_password_token = @user.tokens.create(my_app: @my_app, expires_at: expires_at) # @current_user.tokens.create(my_app: @my_app)
        # @user.reset_password_token = @reset_password_token.token
        @user.update(reset_password_token: @reset_password_token.token, status: 'SV')
        unless @role.nil?
          @role_options = RoleOption.where(role_id: @role.id)
          create_user_options unless @role_options.nil?
        end
        @mailer_mail_to = if @mailer_mode == 'TEST'
                            @mailer_test_email
                          else
                            @user.email
                          end
        @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
        SendMailMailer.send_email(@mailer_mail_to,
                                  @user.name,
                                  'FactorGFC - ¡Bienvenido a nuestro sistema de solicitud de credito!',
                                  'Bienvenido a nuestro sistema de solicitud de credito.',
                                  "tu usuario ya fue dado de alta en el sistema, para validar tu correo y crear tu contraseña puedes entrar a la siguiente liga: #{@frontend_url}/#/resetpwd/#{@reset_password_token.token}.
                                  Por motivos de seguridad la liga solo estará vigente 24 horas.").deliver_now
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
            create_user_options unless @role_options.nil?
          end
          render 'api/v1/users/show'
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    elsif @user.update(user_params)
      unless user_params[:role_id].nil?
        @role_options = RoleOption.where(role_id: user_params[:role_id])
        create_user_options unless @role_options.nil?
      end
      render 'api/v1/users/show'
    else
      render json: @user.errors, status: :unprocessable_entity
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
    params.require(:auth).permit(:role_id, :email, :password, :name, :job, :gender, :status, :company_id, :company_signatory) # , :status) #(:email, :password, :name, :role_id)
  end

  def create_user_options
    @role_options.each do |role_option|
      UserOption.custom_update_or_create(@user.id, role_option.option_id)
    end
  end
end
