# frozen_string_literal: true

class Api::V1::CompanySegmentsController < Api::V1::MasterApiController
#  include Swagger::Blocks
#  include Swagger::CompanySegmentsApi

  before_action :authenticate
  before_action :set_company_segment, only: %i[show update destroy]
  before_action :set_company

  # GET /companies/:company_id/company_segments
  def index
    @company_segments = @company.company_segments
  end

  # GET /companies/:company_id/company_segments/2
  def show; end

  # POST /contributors/1/property_documents
  def create
    @company_segment = @company.company_segments.new(company_segment_params)
    if @company_segment.save
      render template: 'api/v1/company_segments/show'
    else
      render json: { error: @company_segment.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /companies/:company_id/company_segments/2
  def update
    if @company_segment.update(company_segment_params)
      render template: 'api/v1/company_segments/show'
    else
      render json: { error: @company_segment.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/company_segments/1
  def destroy
    @company_segment.destroy
    render json: { message: 'El segmento de la cadena fue eliminado' }
  end

  private

  def company_segment_params
    params.require(:company_segment).permit(:key, :company_rate, :credit_limit, :max_period, :commission, :currency)
  end

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_company_segment
    @company_segment = CompanySegment.find(params[:id])
  end
end
