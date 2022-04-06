# frozen_string_literal: true

class Api::V1::SimCustomerCreditsController < Api::V1::MasterApiController

  before_action :authenticate

  def sim_credit
    @error_desc = []
    ActiveRecord::Base.transaction do
        create_customer_credit(sim_credit_params[:total_requested], 'SI', DateTime.now, sim_credit_params[:customer_id], sim_credit_params[:term_id], sim_credit_params[:payment_period_id],
                               sim_credit_params[:rate], sim_credit_params[:iva_percent])
        if @customer_credit.blank?
          error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
          raise ActiveRecord::Rollback
        else
          render 'api/v1/customer_credits/show'
          raise ActiveRecord::Rollback
        end
    end
  end

  private

  def sim_credit_params
    params.require(:sim_credit).permit(:total_requested, :customer_id, :term_id, :payment_period_id, :rate, :iva_percent)
  end
end
