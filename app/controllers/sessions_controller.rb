# frozen_string_literal: true

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
end
