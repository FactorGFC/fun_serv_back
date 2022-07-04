# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

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

  def get_callback
    @error_desc = []
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
      if @customer_credit[0].extra2 > Time.now
        if @customer_credit.blank?
          @error_desc.push("No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}")
          error_array!(@error_desc, :not_found)
        else
          if @customer_credit[0].status == 'PROPUESTO'
            @customer_credit.update(status: 'ACEPTADO')
            @customer_credit.update(extra3: "#{params[:call_back_token]}-ACEPTADO")
            render json: { message: 'Ok, Credito actualizado con exito' }, status: 200
          else
            @error_desc.push("El credito ya ha sido actualizado por el cliente #{@customer_credit.status}")
            error_array!(@error_desc, :not_found)
          end
        end
    else
      @error_desc.push("El token ha expirado.")
      error_array!(@error_desc, :not_found)
    end
  end

  def get_callback_decline
    @error_desc = []
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    if @customer_credit[0].extra2 > Time.now
      if @customer_credit.blank?
        @error_desc.push("No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}")
        error_array!(@error_desc, :not_found)
      else
        if @customer_credit[0].status == 'PROPUESTO'
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
end
