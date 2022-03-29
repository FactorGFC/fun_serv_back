# frozen_string_literal: true

class Api::V1::RoleOptionsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::RoleOptionsApi

  before_action :authenticate
  before_action :set_role_option, only: %i[update destroy]
  def create
    # params {poll_id: 1, answers_id: 2}
    role = Role.find(params[:role_id])
    option = Option.find(params[:option_id])
    @role_option = RoleOption.custom_update_or_create(role, option)

    if @role_option
      render template: 'api/v1/role_options/show'
    else
      error_array!(@role_option.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @role_option.destroy
    render json: { message: 'Fué eliminada la opción para el rol indicado' }
  end

  private

  def set_role_option
    @role_option = RoleOption.find(params[:id])
  end
end
