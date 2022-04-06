# frozen_string_literal: true

class Api::V1::CompaniesController < Api::V1::MasterApiController
    include Swagger::Blocks
    include Swagger::CompaniesApi
  
    before_action :authenticate
    before_action :set_company, only: %i[show update destroy]
    before_action :set_contributor
  
    # GET /contributors/:contributor_id/companies
    def index
      @companies = @contributor.companies
    end
  
    # GET /contributors/:contributor_id/companies/2
    def show; end
  
    # POST /contributors/1/companies
    def create
      @company = @contributor.companies.new(company_params)
      if @company.save
        @contributor.update(extra3: 'SI')
        render template: 'api/v1/companies/show'
      else
        render json: { error: @company.errors }, status: :unprocessable_entity
      end
    end
  
    # PATCH PUT /contributors/:contributor_id/companies/2
    def update
      if @company.update(company_params)
        render template: 'api/v1/companies/show'
      else
        render json: { error: @companies.errors }, status: :unprocessable_entity
      end
    end
  
    # DELETE /contributors/1/companies/1
    def destroy
      @company.destroy
      render json: { message: 'La cadena fue eliminada' }
    end
  
    private
  
    def company_params
      params.require(:company).permit(:business_name, :start_date, :credit_limit, :credit_available, :document, :sector, :subsector, :company_rate)
    end
  
    def set_contributor    
      unless params[:contributor_id].blank?
        @contributor = Contributor.find(params[:contributor_id])
      end
    end
  
    def set_company
      @company = Company.find(params[:id])
    end
  end
  