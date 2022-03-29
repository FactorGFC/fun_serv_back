# frozen_string_literal: true

class Api::V1::UserPrivilegesController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::UserPrivilegesApi

  before_action :authenticate
  before_action :set_user_privilege, only: %i[show update destroy]
  before_action :set_user

  # GET /users/:user_id/user_privileges
  def index
    @user_privileges = @user.user_privileges
  end

  # GET /users/:user_id/user_privileges/2
  def show; end

  # POST /users/1/user_privileges
  def create
    @user_privileges = @user.user_privileges.new(user_privilege_params)
    if @user_privileges.save
      render template: 'api/v1/user_privileges/show'
    else
      render json: { error: @user_privileges.errors }, status: :unprocessable_entity
    end
  end

  # PATCH PUT /users/:user_id/user_privileges/2
  def update
    if @user_privileges.update(user_privilege_params)
      render template: 'api/v1/user_privileges/show'
    else
      render json: { error: @user_privileges.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/user_privileges/1
  def destroy
    @user_privileges.destroy
    render json: { message: 'El privilegio del usuario fue eliminado' }
  end

  private

  def user_privilege_params
    params.require(:user_privilege).permit(:user_id, :key, :description, :value, :documentation)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_user_privilege
    @user_privileges = UserPrivilege.find(params[:id])
  end
end
