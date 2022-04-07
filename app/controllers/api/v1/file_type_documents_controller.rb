# frozen_string_literal: true

class Api::V1::FileTypeDocumentsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::FileTypeDocumentsApi
  
  before_action :authenticate
  before_action :set_file_type_document, only: %i[update destroy]
  def create
    # params {poll_id: 1, answers_id: 2}
    file_type = FileType.find(params[:file_type_id])
    document = Document.find(params[:document_id])
    @file_type_document = FileTypeDocument.custom_update_or_create(file_type, document)

    if @file_type_document
      render template: 'api/v1/file_type_documents/show'
    else
      error_array!(@file_type_document.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @file_type_document.destroy
    render json: { message: 'Fué eliminada el documento para el tipo de expediente indicado' }
  end

  private

  def set_file_type_document
    @file_type_document = FileTypeDocument.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el documento prara el tipo de archivo con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end
end
