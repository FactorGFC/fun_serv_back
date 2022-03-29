# frozen_string_literal: true

class Api::V1::PeopleController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::PeopleApi

  before_action :authenticate
  before_action :set_person, only: %i[show update destroy]

  def index
    @people = Person.all
  end

  def show; end

  def create
    @person = Person.new(people_params)
    if @person.save
      render 'api/v1/people/show'
    else
      error_array!(@person.errors.full_messages, :unprocessable_entity)
    end
  end

  def update
    @person.update(people_params)
    render 'api/v1/people/show'
  end

  def destroy
    @person.destroy
    render json: { message: 'Fué eliminada la persona física indicada' }
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def people_params
    params.require(:person).permit(:fiscal_regime, :rfc, :curp, :imss, 
                   :first_name, :last_name, :second_last_name, :gender, 
                   :nationality, :birth_country, :birthplace, :birthdate, 
                   :martial_status, :id_type, :identification, :phone, 
                   :mobile, :email, :fiel, :extra1, :extra2, :extra3)
  end
end
