# frozen_string_literal: true

class Api::V1::StatesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::StatesApi

  before_action :authenticate
  before_action :set_state, only: %i[show]
  before_action :set_country

  # GET /countries/:country_id/states
  def index
    @states = @country.states
  end

  # GET /countries/:country_id/states/2
  def show; end

  private

  def set_country
    @country = Country.find(params[:country_id])
  end

  def set_state
    @state = State.find(params[:id])
  end
end
