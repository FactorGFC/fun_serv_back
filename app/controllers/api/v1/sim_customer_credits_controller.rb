# frozen_string_literal: true

class Api::V1::SimCustomerCreditsController < Api::V1::MasterApiController
  #include Swagger::Blocks
  #include Swagger::PostalCodesApi

  before_action :authenticate

  def sim_credit
    @error_desc = []
    ActiveRecord::Base.transaction do
      sim_rates = Rate.where(term_id: sim_credit_params[:term_id], payment_period_id: sim_credit_params[:payment_period_id])      
      sim_rate = sim_rates[0]
      if sim_rate.blank?
        @error_desc.push("No existe una tasa con el term_id: #{sim_credit_params[:term_id]} y con el payment_period_id: #{sim_credit_params[:payment_period_id]}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        create_customer_credit(sim_credit_params[:total_requested], 'SI', DateTime.now, sim_credit_params[:customer_id], sim_credit_params[:term_id], sim_credit_params[:payment_period_id], sim_rate.value, nil, nil)
        unless @customer_credit.blank?
          render 'api/v1/customer_credits/show'
          raise ActiveRecord::Rollback
        else
          error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  private

  def sim_credit_params
    params.require(:sim_credit).permit(:total_requested, :customer_id, :term_id, :payment_period_id, :rate)
  end
end
