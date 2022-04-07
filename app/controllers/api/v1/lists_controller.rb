# frozen_string_literal: true

class Api::V1::ListsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::ListsApi
  
  before_action :authenticate
  before_action :set_list, only: %i[show update destroy]

  def index
    @lists = List.all
  end

  def show; end

  def create
    @list = List.new(lists_params)
    if @list.save
      render 'api/v1/lists/show'
    else
      error_array!(@list.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @list.update(lists_params)
    render 'api/v1/lists/show'
  end

  def destroy
    @list.destroy
    render json: { message: 'Fué eliminada la lista indicada' }
  end

  def domain
    @lists = List.where(domain: params[:domain])
  end

  private

  def set_list
    @list = List.find(params[:id])
  end

  def lists_params
    params.require(:list).permit(:domain, :key, :value, :description)
  end
end
