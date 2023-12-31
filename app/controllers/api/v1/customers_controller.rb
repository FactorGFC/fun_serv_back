# frozen_string_literal: true

class Api::V1::CustomersController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CustomersApi

  require 'json'
  
  before_action :authenticate
  before_action :set_customer, only: %i[show update destroy]
  before_action :set_contributor , only: %i[index show update destroy create] 

  # GET /contributors/:contributor_id/customers
  def index
    @customers = @contributor.customers
  end

  # GET /contributors/:contributor_id/customers/2
  def show; end

  # POST /contributors/1/customers
  def create
    @customer = @contributor.customers.new(customer_params)
    ActiveRecord::Base.transaction do
      unless @customer.customer_type.blank?
        @file_types = FileType.where(customer_type: @customer.customer_type)
        if @file_types.blank?
          @error_desc = []
          @error_desc.push("No se encontró un tipo de expediente para el tipo de cliente: #{@customer.customer_type}")
          error_array!(@error_desc, :not_found)
        else
          create_contributor_documents
          @customer.file_type_id = @file_types[0].id
          if @customer.save
            render template: 'api/v1/customers/show'
          else
            render json: { error: @customer.errors }, status: :unprocessable_entity
          end
        end
      end
    end
  end

  # PATCH PUT /contributors/:contributor_id/customers/2
  def update
    if @customer.update(customer_params)
      render template: 'api/v1/customers/show'
    else
      render json: { error: @customers.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /contributors/1/customers/1
  def destroy
    @customer.destroy
    render json: { message: 'El cliente fue eliminado' }
  end

  # GET CREDIT BUREAU REPORT QUE DEVUELVE EL JSON GUARDADO EN LA TABLA

  def credit_bureau_report
    @bureau_report = CreditBureau.where(customer_id: params[:customer_id]).last
      unless @bureau_report.blank?
        render template: 'api/v1/credit_bureaus/bureau'
      else
        render json: { message: "No se encuentra reporte de buro para el id:  #{params[:customer_id]}"}, status: 206
      end
  end

  private

  def customer_params
    params.require(:customer).permit(:attached, :customer_type, :name, :status, :user_id,
                                     :salary_period, :salary, :other_income, :net_expenses,
                                     :family_expenses, :house_rent, :credit_cp, :credit_lp,
                                     :immediate_superior, :seniority, :ontime_bonus, :assist_bonus,
                                     :food_vouchers, :total_income, :total_savings_food,
                                     :chrismas_bonus, :taxes, :imms, :savings_found,
                                     :savings_found_loand, :savings_bank, :insurance_discount,
                                     :child_support, :extra_expenses, :infonavit, :company_id, :job
                                     )
  end

  def set_contributor
    @contributor = Contributor.find(params[:contributor_id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el contribuyente con el id: #{params[:contributor_id]}")
    error_array!(@error_desc, :not_found)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el cliente con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def create_contributor_documents
    @file_type_documents = FileTypeDocument.where(file_type_id: @file_types[0].id)
    @file_type_documents.each do |file_type_document|
      @documents = Document.where(id: file_type_document.document_id)
      unless @documents.blank?
        ContributorDocument.custom_update_or_create(@contributor.id, file_type_document.id, @documents[0].name, 'PI') # PI - Por ingresar, estatus inicial
      end
    end
  end 

end
