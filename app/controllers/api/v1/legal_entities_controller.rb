# frozen_string_literal: true

class Api::V1::LegalEntitiesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::LegalEntitiesApi
  
  before_action :authenticate
  before_action :set_legal_entity, only: %i[show update destroy]

  def index
    @legal_entities = LegalEntity.all
  end

  def show; end

  def create
    @legal_entity = LegalEntity.new(legal_entities_params)
    if @legal_entity.save
      render 'api/v1/legal_entities/show'
    else
      error_array!(@legal_entity.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @legal_entity.update(legal_entities_params)
    render 'api/v1/legal_entities/show'
  end

  def destroy
    @legal_entity.destroy
    render json: { message: 'Fué eliminada la persona moral indicada' }
  end

  private

  def set_legal_entity
    @legal_entity = LegalEntity.find(params[:id])
  end

  def legal_entities_params
    params.require(:legal_entity).permit(:fiscal_regime,
                                         :rfc, :rug, :business_name, :phone, :mobile, :email,
                                         :business_email, :main_activity, :fiel, :extra1, :extra2, :extra3)
  end
end
