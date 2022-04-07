# frozen_string_literal: true

class Api::V1::ContributorDocumentsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ContributorDocumentsApi
  
  before_action :authenticate
  before_action :set_contributor_document, only: %i[show update destroy]
  before_action :set_contributor

  # GET /contributors/:contributor_id/contributor_documents
  def index
    @contributor_documents = @contributor.contributor_documents
  end

  # GET /contributors/:contributor_id/contributor_documents/2
  def show; end

  # POST /contributors/:contributor_id/contributor_documents
  def create
    @contributor_document = @contributor.contributor_documents.new(contributor_document_params)
    if @contributor_document.save
      render template: 'api/v1/contributor_documents/show'
    else
      render json: { error: @contributor_document.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /contributors/:contributor_id/contributor_documents/2
  def update
    if @contributor_document.update(contributor_document_params)
      render template: 'api/v1/contributor_documents/show'
    else
      render json: { error: @contributor_documents.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/contributor_documents/1
  def destroy
    @contributor_document.destroy
    render json: { message: 'El documento para el contribuyente fue eliminado' }
  end

  private

  def contributor_document_params
    params.require(:contributor_document).permit(:name, :status, :notes, :url, :file_type_document_id)
  end

  def set_contributor
    @contributor = Contributor.find(params[:contributor_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el contribuyente con el id: #{params[:contributor_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_contributor_document
    @contributor_document = ContributorDocument.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el documento del contribuyente con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end
end
