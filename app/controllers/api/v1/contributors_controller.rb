# frozen_string_literal: true

class Api::V1::ContributorsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ContributorsApi
  
  before_action :authenticate
  before_action :set_contributor, only: %i[show update destroy]

  def index
    @contributors = Contributor.all
  end

  def show; end

  def create
    invalid_person = false
    @error_desc = []
    # Validamos que no manden el contribuyente con ids de persona física y moral
    if !contributors_params[:person_id].nil? && !contributors_params[:legal_entity_id].nil?
      invalid_person = true
      @error_desc.push('Se tiene que mandar una persona física o una moral, pero no ambos')
    elsif contributors_params[:person_id].nil? && contributors_params[:legal_entity_id].nil?
      invalid_person = true
      @error_desc.push('Se tiene que mandar una persona física o una moral')
    elsif contributors_params[:person_id].nil?
      # Validamos que el id de la persona física exista, si no, regresamos un 404
      unless contributors_params[:legal_entity_id].nil?
        legal_entity = LegalEntity.where(id: contributors_params[:legal_entity_id])
        if legal_entity.blank?
          invalid_person = true
          @error_desc.push("No se encontró la persona moral con identificador #{contributors_params[:legal_entity_id]}")
        end
      end
    # Validamos que el id de la persona moral exista, si no, regresamos un 404
    else
      person = Person.where(id: contributors_params[:person_id])
      if person.blank?
        invalid_person = true
        @error_desc.push("No se encontró la persona física con identificador #{contributors_params[:person_id]}")
      end
    end
    # A menos que la persona sea inválida gurardamos la transacción
    if invalid_person
      error_array!(@error_desc, :not_found)
    else
      @contributor = Contributor.new(contributors_params)
      if @contributor.save
        render 'api/v1/contributors/show'
      else
        error_array!(@contributor.errors.full_messages, :unprocessable_entity)
      end
    end
  end

  def update
    @contributor.update(contributors_params)
    render 'api/v1/contributors/show'
  end

  def destroy
    @contributor.destroy
    render json: { message: 'Fué eliminado el contribuyente indicado' }
  end

  def get_contributor_registers
    @contributors = Contributor.where(id: params[:id])
    unless @contributors.nil?
      @contributor = @contributors[0]
      if @contributor.contributor_type == 'PM'
        @legal_entities = LegalEntity.where(id: @contributor.legal_entity_id)
        unless @legal_entities.nil?
          @legal_entity = @legal_entities[0]
          render 'api/v1/company_registers/pm_company'
        else
          render json: { message: "No se encontró legal entities" }, status: 206
        end
      elsif @contributor.contributor_type == 'PF'
        @people = Person.where(id: @contributor.person_id)
        unless @people.nil?
          @person = @people[0]
          render 'api/v1/company_registers/pf_company'
        else
          render json: { message: "No se encontró person" }, status: 206
        end
      else
        render json: { message: "El tipo de contributor no es valido contributor_type: #{@contributor.contributor_type}" }, status: :unprocessable_entity
      end
    else
      render json: { message: "No se encontró contributor con el id: #{params[:id]}" }, status: 206
    end
  end

  private

  def set_contributor
    @contributor = Contributor.find(params[:id])
  end

  def contributors_params
    params.require(:contributor).permit(:contributor_type, :bank, :account_number, :clabe, :person_id, :legal_entity_id, :extra1, :extra2, :extra3)
  end
end
