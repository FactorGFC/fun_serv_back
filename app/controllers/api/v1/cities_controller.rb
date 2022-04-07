# frozen_string_literal: true

class Api::V1::CitiesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CitiesApi
  before_action :authenticate
  before_action :set_city, only: %i[show update destroy]
  before_action :set_state

  # GET /states/:state_id/cities
  def index
    @cities = @state.cities
  end

  # GET /states/:state_id/cities/2
  def show; end

  # POST /users/1/user_privileges
  def create
    @city = @state.cities.new(city_params)
    if @city.save
      render template: 'api/v1/cities/show'
    else
      render json: { error: @city.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /states/:state_id/cities/2
  def update
    if @city.update(city_params)
      render template: 'api/v1/cities/show'
    else
      render json: { error: @city.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /states/1/cities/1
  def destroy
    @city.destroy
    render json: { message: 'La ciudad fue eliminada' }
  end

  private

  def city_params
    params.require(:city).permit(:state_id, :name)
  end

  def set_state
    @state = State.find(params[:state_id])
  end

  def set_city
    @city = City.find(params[:id])
  end
end
