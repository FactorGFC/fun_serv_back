# frozen_string_literal: true

class Api::V1::ApiSessionsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ApiSessionsApi
  # POST /users
  def create
    # params = {auth:{ provider: 'facebook', uid:'12asdgsd43'}}
    if !params[:auth]
      render json: { error: 'Falta el parámetro auth' }
    else
      @user = User.from_omniauth(params[:auth])
      if @user
        @token = @user.tokens.create(my_app: @my_app)
        # puts "\n#{"aaaa"}\n #{@token.inspect} \n#{"aaaa"}\n"
        render 'api/v1/users_tokens/show'
      else
        render json: { error: 'Usuario o contraseña inválidos' }, status: :not_found
      end
    end
  end

  def reset_password
    @error_desc = []
    @user_where = User.where(email: params[:email])
    @user = @user_where[0]
    if @user.blank?
      @error_desc.push("El correo electrónico: #{params[:email]} no pertenece a ningún usuario del sistema")
      error_array!(@error_desc, :not_found)
    else
      @reset_password_token = @user.tokens.create(my_app: @my_app)
      if @user.update(reset_password_token: @reset_password_token.token)
        @mailer_mail_to = if @mailer_mode == 'TEST'
                            @mailer_test_email
                          else
                            @user.email
                          end
        @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
        SendMailMailer.send_email(@mailer_mail_to,
                                  @user.name,
                                  'FactorGFC - Cambio de contraseña',
                                  'Recibimos una solicitud para cambiar tu contraseña',
                                  "para cambiar tu contraseña puedes entrar a la siguiente liga: #{@frontend_url}/#{@reset_password_token.token}. 
                                  Por motivos de seguridad la liga solo estará vigente 24 horas.").deliver_now
        render 'api/v1/users_reset_password/show'
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  end

  def get_reset_token
    @error_desc = []
    @user_where = User.where(reset_password_token: params[:reset_password_token])
    @user = @user_where[0]
    if @user.blank?
      @error_desc.push("No se encontró un usuario con el reset token: #{params[:reset_password_token]}")
      error_array!(@error_desc, :not_found)
    else
      render 'api/v1/users/show'
    end
  end
end
