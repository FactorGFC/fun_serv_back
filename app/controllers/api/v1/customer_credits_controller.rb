# frozen_string_literal: true

class Api::V1::CustomerCreditsController < Api::V1::MasterApiController
  include Swagger::Blocks
  include Swagger::CustomerCreditsApi
  
  before_action :authenticate
  before_action :set_customer_credit, only: %i[show update destroy]

  def index
    @customer_credits = CustomerCredit.all
  end

  def show; end

  def create
    @customer_credit = CustomerCredit.new(customer_credits_params)
    ActiveRecord::Base.transaction do
      @capital = 0
      @customer_credit.capital = @capital
      @interests = 0
      @customer_credit.interests = @interests
      @iva = 0
      @customer_credit.iva = @iva
      @total_debt = 0
      @customer_credit.total_debt = @total_debt
      @total_payments = 0
      @customer_credit.total_payments = @total_payments
      @fixed_payment = 0
      @customer_credit.fixed_payment = @fixed_payment
      @customer_credit.balance = 1
     # puts 'balance ' + @customer_credit.balance.inspect
      @end_date = @customer_credit.start_date
      @customer_credit.end_date = @end_date
      if @customer_credit.save
        @terms = Term.where(id: @customer_credit.term_id)
        @term = @terms[0]
        if @term.blank?
          @error_desc.push("No existe un plazo con el id: #{@customer_credit.term_id}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          @payment_periods = PaymentPeriod.where(id: @customer_credit.payment_period_id)
          @payment_period = @payment_periods[0]
          if @payment_period.blank?
            @error_desc.push("No existe un periodo con el id: #{@customer_credit.payment_period_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
         # else
        #    @credit_rating = CreditRating.where(id: @customer_credit.credit_rating_id)
       #     @credit_rating = @credit_rating[0]
      #      if @credit_rating.blank?
     #         @error_desc.push("No existe un periodo con el id: #{@customer_credit.credit_rating}")
    #          error_array!(@error_desc, :not_found)
   #           raise ActiveRecord::Rollback
  #          end
         end
        end
        calculate_customer_payments
        @customer_credit.update(capital: @capital.round(2), interests: @interests.round(2), iva: @iva.round(2), total_debt: @total_debt.round(2), total_payments: @total_payments.round(2),
                                end_date: @end_date, fixed_payment: @fixed_payment.round(2))
        if @customer_credit.status == 'SI'
            render 'api/v1/customer_credits/show'
            raise ActiveRecord::Rollback
        else
          render 'api/v1/customer_credits/show'
        end

      else
        error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    end
  end

  def update
    @customer_credit.update(customer_credits_params)
    render 'api/v1/customer_credits/show'
  end

  def destroy
    @customer_credit.destroy
    render json: { message: 'Fué eliminado el credito al cliente indicado' }
  end

  private

  def set_customer_credit
    @customer_credit = CustomerCredit.find(params[:id])
  end

  def customer_credits_params
    params.require(:customer_credit).permit(:total_requested, :capital, :interests, :iva, :total_debt,
                                            :total_payments, :status, :start_date, :attached,
                                            :rate, :debt_time,:destination, :amount_allowed, :time_allowed, :iva_percent,
                                            :customer_id, :term_id, :payment_period_id, :currency)
  end

  # Metodo que calcula la tabla de amortizacion
  def calculcate_customer_payments2
    @error_desc = []
    customer_credit_id = @customer_credit.id
    term = @term.value # el plazo de pago
  end

  def calculate_customer_payments
    @error_desc = []
    customer_credit_id = @customer_credit.id
    iva_percent = @customer_credit.iva_percent
    #puts '@@@@@@@@@iva' + iva_percent.to_f.inspect
    term = @term.value
    #puts '@@@@@@@@@terms' + term.inspect
    payment_period = @payment_period.value
    total_requested = @customer_credit.total_requested
    rate = @customer_credit.rate
    rate_with_iva = rate.to_f * (1 + (iva_percent.to_f/100))
    #puts '@@@@@@rate_whit_iva' + rate_with_iva.to_f.inspect
    start_date = @customer_credit.start_date
    #puts '@@@@@@start_date' + start_date.inspect
    payment_amount = ((rate_with_iva.to_f/100) * total_requested.to_f) / (1 - ((1 + rate_with_iva.to_f)**-term.to_f))
   # puts '@@@@@@@payment_amount' + payment_amount.to_f.inspect
    @fixed_payment = payment_amount
    @commision = (total_requested.to_f * 0.01) * (1 + (iva_percent.to_f/100))
    #puts '@@@@@@@@comision' + @commision.to_f.inspect
    remaining_debt = 0
    1.upto(term) do |i|
      if i == 1
      interests = 100
        #interests = total_requested.to_f * (rate.to_f/100)
       # puts '########interestsuno' + interests.to_f.inspect
        iva = interests.to_f * (iva_percent.to_f/ 100)
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = total_requested.to_f
        remaining_debt = total_requested.to_f - capital.to_f
        payment = capital.to_f + interests.to_f + iva.to_f
      else
       # interests = remaining_debt.to_f * rate.to_f
       interests = 100
        iva = interests.to_f * (iva_percent.to_f / 100)
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = remaining_debt.to_f
        remaining_debt = remaining_debt.to_f - capital.to_f
        payment = capital.to_f + interests.to_f + iva.to_f
      end
      @capital += capital
      @interests += interests
      @iva += iva
      #Los periodos de pagos deben de ser mensuales, quincenales o semanales
      case payment_period.to_s
      when '12'
        payment_date = start_date + i.months
      when '52'
        payment_date = start_date + (i/4).months
      when '24'
        payment_date = start_date + (i/2).months
      else
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Meses(12), Quincenas(24), Semanas(52)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      start_date = payment_date
      sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: i, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2),
                                                        payment: payment.round(2),
                                                        capital: capital.round(2), interests: interests.round(2), iva: iva.round(2), payment_date: payment_date, status: 'PE')
      if sim_customer_payments.blank?
        @error_desc.push('Ocurrio un error al crear la simulación de los pagos del crédito')
        error_array!(@error_desc, unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      @end_date = payment_date
    end
    @total_debt = @total_debt + @capital + @interests + @iva
  end
end
