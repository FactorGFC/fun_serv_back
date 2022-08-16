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
    @error_desc = []
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless @customer_credit_signatory.blank?
      if @customer_credit[0].extra2 > Time.now
        if @customer_credit.blank?
          @error_desc.push("No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}")
          error_array!(@error_desc, :not_found)
        else
          if @customer_credit[0].status == 'PR'
            @customer_credit.update(status: 'ACEPTADO')
            @customer_credit.update(extra3: "#{params[:call_back_token]}-ACEPTADO")
            render json: { message: 'Ok, Credito actualizado con exito' }, status: 200
            #MANDA UN MAILER A MESA DE CONTROL PARA QUE ANALICE Y DE LUZ VERDE
            send_control_desk_mailer(@customer_credit)
          else
            @error_desc.push("El credito ya ha sido actualizado por el cliente #{@customer_credit.status}")
            error_array!(@error_desc, :not_found)
          end
        end
      else
        @error_desc.push("El token ha expirado.")
        error_array!(@error_desc, :not_found)
      end
    else 
      @error_desc.push( @customer_credit.errors.full_messages,"No encuentra el customer credit")
      error_array!(@error_desc, :unprocessable_entity)
      # raise ActiveRecord::Rollback
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
          @error_desc.push("No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}")
          error_array!(@error_desc, :not_found)
        else
          if @customer_credit[0].status == 'PR'
          @customer_credit.update(status: 'RECHAZADO')
          @customer_credit.update(extra3: "#{params[:call_back_token]}-RECHAZADO")
          render json: { message: 'Ok, Credito actualizado con exito RECHAZADO' }, status: 200
          else
            @error_desc.push("El credito ya ha sido actualizado por el cliente #{@customer_credit[0].status}")
            error_array!(@error_desc, :not_found)
          end

        end
      else
        @error_desc.push("El token ha expirado.")
        error_array!(@error_desc, :not_found)
      end
    else 
      @error_desc.push( @customer_credit.errors.full_messages,"No encuentra el customer credit")
      error_array!(@error_desc, :unprocessable_entity)
    end
  end

  def get_callback_token
    @error_desc = []
    customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless customer_credit.blank?
      if customer_credit[0].extra2 > Time.now
          render json: { message: 'Token Ok', status: true }, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: 'Token expiró', status: false }, status: 206
        @error_desc.push("El token ha expirado.")
        error_array!(@error_desc, :not_found)
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: 'Token de un solo uso ya fué utilizado', status: false
        }, status: 206
    end
  end

  def get_comitee_callback_token
    #OBTIENE EL SIGNATORY_TOKEN_EXPIRATION DE LA TABLA CUSTOMER_CREDITS_SIGNATORIES MEDIANTE EL TOKEN EN PARAMS
    @query = "SELECT * FROM public.customer_credits_signatories
    WHERE signatory_token = ':token'"
    @query = @query.gsub ':token', params[:call_back_token].to_s
    # @customer_credit_signatory = CustomerCreditsSignatory.where(signatory_token: params[:call_back_token])
    @customer_credit_signatory = execute_statement(@query)
    puts "/////////////////////////////////////////////////////////////////////////////////////////"
    puts "@customer_credit_signatory.inspect"
    puts @customer_credit_signatory[0].inspect
    puts "/////////////////////////////////////////////////////////////////////////////////////////"
    unless @customer_credit_signatory[0].blank?
      @signatory_token_expiration = @customer_credit_signatory[0]['signatory_token_expiration']
      if @signatory_token_expiration > Time.now
          render json: { message: 'Token Ok', status: true , credit_id: @customer_credit_signatory[0]["customer_credit_id"]}, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: 'Token expiró', status: false }, status: 206
        # @error_desc.push("El token ha expirado.")
        # error_array!(@error_desc, :not_found)
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: "No se encontró registro", customer_credit_signatory: "#{@customer_credit_signatory[0].inspect}", status: false
        }, status: 206
      # @error_desc.push( ,"No encuentra el customer credit signatory")
      # error_array!(@customer_credit_signatory.errors.full_messages, :unprocessable_entity)
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


end
