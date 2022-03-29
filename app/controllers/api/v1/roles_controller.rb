# frozen_string_literal: true

class Api::V1::RolesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::RolesApi

  before_action :authenticate
  before_action :set_role, only: %i[show update destroy]

  def index
    @roles = Role.all
  end

  def show; end

  def create
    @role = Role.new(roles_params)
    if @role.save
      render 'api/v1/roles/show'
    else
      error_array!(@role.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    if @role.update(roles_params)
      render 'api/v1/roles/show'
    else
      render json: @role.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @role.destroy
    render json: { message: 'Fué eliminado el rol indicado' }
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def roles_params
    params.require(:role).permit(:name, :description)
  end
end
