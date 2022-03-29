# frozen_string_literal: true

class Api::V1::ExtServicesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ExtServicesApi

  before_action :authenticate
  before_action :set_ext_service, only: %i[show update destroy]

  def index
    @ext_services = ExtService.all
  end

  def show; end

  def create
    @ext_service = ExtService.new(ext_services_params)
    if @ext_service.save
      render 'api/v1/ext_services/show'
    else
      error_array!(@ext_service.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @ext_service.update(ext_services_params)
    render 'api/v1/ext_services/show'
  end

  def destroy
    @ext_service.destroy
    render json: { message: 'Fué eliminado el servicio externo indicado' }
  end

  private

  def set_ext_service
    @ext_service = ExtService.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el servicio externo con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def ext_services_params
    params.require(:ext_service).permit(:supplier, :user, :api_key, :token, :url, :rule)
  end
end
