# frozen_string_literal: true

class Api::V1::UserOptionsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::UserOptionsApi
  
  before_action :authenticate
  before_action :set_user_option, only: %i[update destroy]
  def create
    # params {poll_id: 1, answers_id: 2}
    user = User.find(params[:user_id])
    option = Option.find(params[:option_id])
    @user_option = UserOption.custom_update_or_create(user, option)

    if @user_option
      render template: 'api/v1/user_options/show'
    else
      error_array!(@user_option.errors.full_messages, :unprocessable_entity)
    end
  end

  def destroy
    @user_option.destroy
    render json: { message: 'Fué eliminado la opción para el usuario indicado' }
  end

  private

  def set_user_option
    @user_option = UserOption.find(params[:id])
  end
end
