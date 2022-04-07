# frozen_string_literal: true

class Api::V1::DocumentsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::DocumentsApi
  
  before_action :authenticate
  before_action :set_document, only: %i[show update destroy]

  def index
    @documents = Document.all
  end

  def show; end

  # POST /documents
  def create
    @ext_service = ExtService.find(document_params[:ext_service_id]) unless document_params[:ext_service_id].nil?
    @document = if @ext_service.nil?
                  Document.new(document_params)
                else
                  @ext_service.documents.new(document_params)
                end
    if @document.save
      render 'api/v1/documents/show'
    else
      render json: { error: @document.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @document.update(document_params)
      render 'api/v1/documents/show'
    else
      render json: @document.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    render json: { message: 'El documento fue eliminado' }
  end

  private

  def set_document
    @document = Document.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el documento con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def document_params
    params.require(:document).permit(:ext_service_id, :document_type, :name, :description, :validation)
  end
end
