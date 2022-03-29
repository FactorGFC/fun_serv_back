# frozen_string_literal: true

class Api::V1::TermsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::TermsApi
  
  before_action :authenticate
  before_action :set_term, only: %i[show update destroy]

  def index
    @terms = Term.all
  end

  def show; end

  def create
    @term = Term.new(terms_params)
    if @term.save
      render 'api/v1/terms/show'
    else
      error_array!(@term.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @term.update(terms_params)
    render 'api/v1/terms/show'
  end

  def destroy
    @term.destroy
    render json: { message: 'Fué eliminado el plazo indicado' }
  end

  private

  def set_term
    @term = Term.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el plazo con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def terms_params
    params.require(:term).permit(:key, :description, :value, :term_type, :credit_limit)
  end
end
