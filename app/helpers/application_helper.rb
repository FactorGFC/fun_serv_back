# frozen_string_literal: true

module ApplicationHelper
  def user_signed_in?
    # Devolverá verdadero si hay un usuario logeado y falso si no hay usuario logeado
    !current_user.nil? # Devuelve verdadero si el objeto es nulo o caso contrario devuelve falso
  end

  def current_user
    # Devolverá nil si hay un usuario logeado o devolverá el usuario logeado
    User.where(id: session[:user_id]).first
  end
end
