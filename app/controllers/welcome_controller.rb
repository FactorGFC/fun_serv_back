# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index; end

  def app
    @my_apps = current_user.my_apps
  end

  def ok
    render json: { message: 'Ok' }, status: 200
  end
end
