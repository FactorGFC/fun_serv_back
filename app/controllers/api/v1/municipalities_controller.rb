# frozen_string_literal: true

class Api::V1::MunicipalitiesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::MunicipalitiesApi

  before_action :authenticate
  before_action :set_municipality, only: %i[show update destroy]
  before_action :set_state

  # GET /states/:state_id/municipalities
  def index
    @municipalities = @state.municipalities
  end

  # GET /states/:state_id/municipalities/2
  def show; end

  # POST /users/1/user_privileges
  def create
    @municipality = @state.municipalities.new(municipality_params)
    if @municipality.save
      render template: 'api/v1/municipalities/show'
    else
      render json: { error: @municipality.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /states/:state_id/municipalities/2
  def update
    if @municipality.update(municipality_params)
      render template: 'api/v1/municipalities/show'
    else
      render json: { error: @municipality.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /states/1/municipalities/1
  def destroy
    @municipality.destroy
    render json: { message: 'El municipio fue eliminado' }
  end

  private

  def municipality_params
    params.require(:municipality).permit(:municipality_key, :name)
  end

  def set_state
    @state = State.find(params[:state_id])
  end

  def set_municipality
    @municipality = Municipality.find(params[:id])
  end
end
