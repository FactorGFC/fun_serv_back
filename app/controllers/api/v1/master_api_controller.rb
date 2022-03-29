# frozen_string_literal: true

# Rocktore 13/02/2020
# Esta clase se utilizará para validar la seguridad de las 
# APIs por medio del metodo authenticate_app para validar
# que las peticiones vengan con un app_id o secret_key valido
# de tal forma que el resto de los controladores deberán 
# heredar de esta clase. Se valida el origen de las peticiones
# por medio de los cors headers.
class Api::V1::MasterApiController < ApplicationController
  layout 'api/v1/application'

  before_action :cors_set_access_control_headers
  before_action :authenticate_app, except: [:xhr_options_request]

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = request.headers['origin'].to_s
    headers['Access-Control-Allow-Methods'] = 'POST,GET,PUT,DELETE,OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin,Content-Type,Accept,Authoritation,Token'
  end

  def xhr_options_request
    head :ok
  end

  private

  def authenticate_app
    if params.key?(:app_id)
      @my_app = MyApp.find_by(app_id: params[:app_id])
      # origen_headers = request.headers["origin"]
      # origen_valido_comparado = @my_app.is_valid_origin(request.headers["origin"])
      # puts "\n#{"Valor de cors del header:"}\n #{origen_headers} \n#{">>>>>>>>>>"}\n"
      # puts "\n#{"Valor del origen ya comparado:"}\n #{origen_valido_comparado} \n#{">>>>>>>>>>"}\n"
      if @my_app.nil? || !@my_app.is_valid_origin?(request.headers['origin'])
        error!('App ID inválido u origen incorrecto', :unauthorized)
      end
    elsif params.key?(:secret_key)
      @my_app = MyApp.find_by(secret_key: params[:secret_key])
      error!('Secret Key inválido', :unauthorized) if @my_app.nil?
    else
      error!('Necesitas una aplicación para comunicarte con el API', :unauthorized)
    end
  end
end
