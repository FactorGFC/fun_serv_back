# frozen_string_literal: true
require 'json'

class SessionsController < ApplicationController

  def create
    auth = { email: params[:email], password: params[:password] }
    user = User.from_omniauth(auth)

    if !user.nil?
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to '/my_apps' }
      end
    else
      redirect_to '/', notice: 'Combinación de correo/contraseña inválida'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end

#CUANDO EL CLIENTE/EMPLEADO ACEPTA EL CREDITO
  def get_callback
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless @customer_credit.blank?
      if @customer_credit[0].extra2 > Time.now
          if @customer_credit[0].status == 'PR'
            @customer_credit.update(status: 'AC')
            @customer_credit.update(extra3: "#{params[:call_back_token]}-AC")
            #MANDA UN MAILER A MESA DE CONTROL PARA QUE ANALICE Y DE LUZ VERDE
            send_control_desk_mailer(@customer_credit[0].id)
            render json: { message: 'Ok, Credito actualizado con exito (ACEPTADO)' }, status: 200
          else
            render json: { message: "El credito ya ha sido actualizado por el cliente #{@customer_credit.status}", status: false }, status: 206
          end
      else
        render json: { message: "Token expiró el #{@customer_credit[0].extra2}", status: false }, status: 206
      end
    else 
      render json: { message: "No encuentra el customer credit", place: "get_callback",status: false }, status: 206
    end
  end

#MAILER DE ESTADO DE CUENTA
  def send_account_status_mailer
    @id = params[:id]
    response = PaymentCredit.get_credit_payments(@id)
    unless response.blank?
      SendMailMailer.send_email_account_status(
            "dgonzalez@factorgfc.com", #response[0]['email'],
            response[0]['name'],
            "Estado de cuenta",
            "Estado de cuenta",
            response
          ).deliver_now
      render json: { message: response }, status: 200
    else
      render json: { message: 'No se encontraron registros' }, status: 400
    end
  end


#CUANDO EL CLIENTE/EMPLEADO RECHAZA EL CREDITO
  def get_callback_decline
    @error_desc = []
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless @customer_credit.blank?
      if @customer_credit[0].extra2 > Time.now
        if @customer_credit.blank?
          render json: { message: "No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}", status: false }, status: 206
        else
          if @customer_credit[0].status == 'PR'
          @customer_credit.update(status: 'RE')
          @customer_credit.update(extra3: "#{params[:call_back_token]}-RE")
          render json: { message: 'Ok, Credito actualizado con exito (RECHAZADO)' }, status: 200
          else
            render json: { message: "El credito ya ha sido actualizado por el cliente (#{@customer_credit[0].status})", status: false }, status: 206
          end

        end
      else
        render json: { message: "Token expiró el #{@customer_credit[0].extra2}", status: false }, status: 206
      end
    else 
      render json: { message: "No encuentra el customer credit", status: false }, status: 206
    end
  end

  def get_callback_token
    @error_desc = []
    customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless customer_credit.blank?
      if customer_credit[0].extra2 > Time.now
          render json: { message: 'Token vigente', status: true }, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: "Token expiró el #{customer_credit[0].extra2}", status: false }, status: 206
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: 'Token de un solo uso ya fué utilizado', status: false
        }, status: 206
    end
  end

  def get_comitee_callback_token
    @customer_credit_signatory = CustomerCreditsSignatory.where(signatory_token: params[:call_back_token])
    unless @customer_credit_signatory.blank?
      @signatory_token_expiration = @customer_credit_signatory[0].signatory_token_expiration
      if @signatory_token_expiration > Time.now
          render json: { message: 'Token Ok', status: true , credit_id: @customer_credit_signatory[0]["customer_credit_id"]}, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: 'Token expiró', status: false }, status: 206
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: "No se encontró registro", customer_credit_signatory: "#{@customer_credit_signatory[0].inspect}", status: false
        }, status: 206
    end
  end

  def mailer_mode_to (email)
    if @mailer_mode == 'TEST'
      @mailer_mail_to = @mailer_test_email
    else
      @mailer_mail_to = email
    end
    @mailer_mail_to
  end

  def update_user
    @user = User.where(reset_password_token: params['reset_password_token'])
      unless @user.blank?
        if @user.update(password: params['password'],reset_password_token: "#{params['reset_password_token']}-utilizado" )
          render json: { message: 'Update ok', status: true , user: @user.inspect}, status: 200
        else
          render json: { message: "Hubo un error al actualizar contraseña", user: "#{@user.inspect}", status: false}, status: 206
        end
      else
        # NO SE ENCONTRÓ EL TOKEN
      render json: { message: "No se encontró registro", user: "#{@user.inspect}", status: false}, status: 206
      end
  end

  def get_reset_pwd_token
    @user_where = User.where(reset_password_token: params[:reset_password_token])
    @user = @user_where[0]
    if @user.blank?
      render json: { message: "No se encontró registro", user: "#{@user.inspect}", status: false}, status: 206
    else
      render json: { message: 'Ok', status: true , user: @user.inspect}, status: 200
    end
  end

end
