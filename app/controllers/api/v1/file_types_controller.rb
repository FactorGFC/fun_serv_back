# frozen_string_literal: true

class Api::V1::FileTypesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::FileTypesApi

  before_action :authenticate
  before_action :set_file_type, only: %i[show update destroy]

  def index
    @file_types = FileType.all
  end

  def show; end

  def create
    @file_type = FileType.new(file_types_params)
    if @file_type.save
      render 'api/v1/file_types/show'
    else
      error_array!(@file_type.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @file_type.update(file_types_params)
    render 'api/v1/file_types/show'
  end

  def destroy
    @file_type.destroy
    render json: { message: 'Fué eliminado el tipo de expediente indicado' }
  end

  private

  def set_file_type
    @file_type = FileType.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el tipo de expediente con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def file_types_params
    params.require(:file_type).permit(:name, :description, :customer_type, :funder_type)
  end
end
