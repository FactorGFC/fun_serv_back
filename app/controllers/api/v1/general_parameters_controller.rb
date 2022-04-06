# frozen_string_literal: true

class Api::V1::GeneralParametersController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::GeneralParametersApi
  
  before_action :authenticate
  before_action :set_general_parameter, only: %i[show update destroy]

  def index
    @general_parameters = GeneralParameter.all
  end

  def show; end

  def create
    @general_parameter = GeneralParameter.new(general_parameters_params)
    if @general_parameter.save
      render 'api/v1/general_parameters/show'
    else
      error_array!(@general_parameter.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @general_parameter.update(general_parameters_params)
    render 'api/v1/general_parameters/show'
  end

  def destroy
    @general_parameter.destroy
    render json: { message: 'Fué eliminado el parámetro general indicado' }
  end

  private

  def set_general_parameter
    @general_parameter = GeneralParameter.find(params[:id])
  end

  def general_parameters_params
    params.require(:general_parameter).permit(:table, :id_table, :key, :description, :used_values, :value, :documentation)
  end
end
