# frozen_string_literal: true

class Api::V1::OptionsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::OptionsApi
  
  before_action :authenticate
  before_action :set_option, only: %i[show update destroy]

  def index
    @options = Option.all
  end

  def show; end

  def create
    @option = Option.new(options_params)
    if @option.save
      render 'api/v1/options/show'
    else
      error_array!(@option.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @option.update(options_params)
    render 'api/v1/options/show'
  end

  def destroy
    @option.destroy
    render json: { message: 'Fué eliminada la opción indicada' }
  end

  private

  def set_option
    @option = Option.find(params[:id])
  end

  def options_params
    params.require(:option).permit(:name, :description, :group, :url)
  end
end
