# frozen_string_literal: true

class Api::V1::FundersController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::FundersApi

  before_action :authenticate
  before_action :set_funder, only: %i[show update destroy]
  before_action :set_contributor

  # GET /contributors/:contributor_id/funders
  def index
    @funders = @contributor.funders
  end

  # GET /contributors/:contributor_id/funders/2
  def show; end

  # POST /contributors/1/funders
  def create
    @funder = @contributor.funders.new(funder_params)
    ActiveRecord::Base.transaction do    
      unless @funder.funder_type.blank?
        @file_types = FileType.where(funder_type: @funder.funder_type)
        unless @file_types.blank?
          create_contributor_documents
          @funder.file_type_id = @file_types[0].id
          if @funder.save
            render template: 'api/v1/funders/show'
          else
            render json: { error: @funder.errors }, status: :unprocessable_entity
          end
        else
          @error_desc = []
          @error_desc.push("No se encontró un tipo de expediente para el tipo de inversionista: #{@funder.funder_type}")
          error_array!(@error_desc, :not_found)  
        end
      end
    end
  end

  # PATCH PUT /contributors/:contributor_id/funders/2
  def update
    if @funder.update(funder_params)
      render template: 'api/v1/funders/show'
    else
      render json: { error: @funders.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/funders/1
  def destroy
    @funder.destroy
    render json: { message: 'El inversionista fue eliminado' }
  end

  private

  def funder_params
    params.require(:funder).permit(:attached, :funder_type, :name, :status, :user_id)
  end

  def set_contributor
    @contributor = Contributor.find(params[:contributor_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el contribuyente con el id: #{params[:contributor_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_funder
    @funder = Funder.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el inversionista con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def create_contributor_documents
    @file_type_documents = FileTypeDocument.where(file_type_id: @file_types[0].id)
    @file_type_documents.each do |file_type_document|
      @documents = Document.where(id: file_type_document.document_id)
      unless @documents.blank?
        ContributorDocument.custom_update_or_create(@contributor.id, file_type_document.id, @documents[0].name, 'PI') #PI - Por ingresar, estatus inicial
      end
    end
  end
end
