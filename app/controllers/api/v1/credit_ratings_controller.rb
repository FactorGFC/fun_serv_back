class Api::V1::CreditRatingsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CreditRatingsApi
  before_action :authenticate
  before_action :set_credit_rating, only: %i[show update destroy]

  def index
    @credit_ratings = CreditRating.all
  end

  def show; end

  def create
    @credit_rating = CreditRating.new(credit_ratings_params)
    if @credit_rating.save
      render 'api/v1/credit_ratings/show'
    else
      error_array!(@credit_rating.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @credit_rating.update(credit_ratings_params)
    render 'api/v1/credit_ratings/show'
  end

  def destroy
    @credit_rating.destroy
    render json: { message: 'Fué eliminada la clasificación de crédito' }
  end

  private

  def set_credit_rating
    @credit_rating = CreditRating.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @error_desc = []
    @error_desc.push("No se encontró el la clasificación de crédido con el id: #{params[:id]}")
    error_array!(@error_desc, :not_found)
  end

  def credit_ratings_params
    params.require(:credit_rating).permit(:key, :description, :value, :cr_type)
  end
end