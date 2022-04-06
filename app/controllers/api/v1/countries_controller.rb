# frozen_string_literal: true

class Api::V1::CountriesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CountriesApi
  
  before_action :authenticate
  before_action :set_country, only: %i[show]

  def index
    @countries = Country.all
  end

  def show; end

  private

  def set_country
    @country = Country.find(params[:id])
  end
end
