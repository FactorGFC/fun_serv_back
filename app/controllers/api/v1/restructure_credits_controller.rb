# frozen_string_literal: true

class Api::V1::RestructureCreditsController < Api::V1::MasterApiController
  # include Swagger::Blocks
  # include Swagger::PostalCodesApi

  before_action :authenticate

  def term
    @error_desc = []
    ActiveRecord::Base.transaction do
      @customer_credits = CustomerCredit.where(id: restructure_credits_params[:customer_credit_id])
      @customer_credit = @customer_credits[0]
      if @customer_credit.blank?
        @error_desc.push("No existe un crédito con el id: #{restructure_credits_params[:customer_credit_id]}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        @fixed_payment = @customer_credit.fixed_payment
        customer_payment = @customer_credit.pending_payments.first
        if customer_payment.blank?
          @error_desc.push('No se encontraron pagos pendientes')
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          payment_capital = restructure_credits_params[:total_payment].to_f - customer_payment.interests.to_f - customer_payment.iva.to_f
          @current_payment_capital = payment_capital
          current_debt_total = customer_payment.current_debt.to_f + customer_payment.interests.to_f + customer_payment.iva.to_f
          if restructure_credits_params[:total_payment].to_f > current_debt_total.to_f.round(2)
            @error_desc.push("El pago no puede ser mayor al adeudo pendiente: #{current_debt_total.round(2)}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          elsif restructure_credits_params[:total_payment].to_f < @fixed_payment.to_f && current_debt_total.to_f.round(2) > @fixed_payment.to_f
            @error_desc.push("A menos que el resto del adeudo sea menor al pago fijo, el pago no puede ser menor al pago fijo: #{@fixed_payment}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          elsif restructure_credits_params[:total_payment].to_f < @fixed_payment.to_f && restructure_credits_params[:total_payment].to_f < current_debt_total.to_f.round(2)
            @error_desc.push("Si el adeudo restante es menor al pago fijo, se debe de pagar el total del adeudo restante: #{current_debt_total.to_f.round(2)}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          else
            @payment_remaining_debt = customer_payment.current_debt - payment_capital
            customer_payment.capital = payment_capital.round(2)
            customer_payment.payment = restructure_credits_params[:total_payment].to_f
            customer_payment.remaining_debt = @payment_remaining_debt.round(2)
            customer_payment.status = 'PA'
            customer_payment.extra1 = 'Se actualiza el pago con el abono a capital correspondiente'
            total_payments = @customer_credit.total_payments + restructure_credits_params[:total_payment].to_f
            @customer_credit.total_payments = total_payments
            @max_num_payment = customer_payment.pay_number
            @current_payment = customer_payment.pay_number
            @last_date = customer_payment.payment_date
          end
          if customer_payment.save
            @update_pending_payments_sql = "update sim_customer_payments set status=':new_status', extra1= ':comment' where customer_credit_id=':customer_credit_id'
                                            and status = ':current_status';"
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':new_status', 'CA'
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':comment', "Se cancela el pago por reestructuración en plazo, se abonó a capital: #{payment_capital.round(2)}"
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':customer_credit_id', @customer_credit.id.to_s
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':current_status', 'PE'
            @update_pending_payments = ActiveRecord::Base.connection.update(@update_pending_payments_sql)
          else
            @error_desc.push('No se pudo actualzar el pago actual con el abono a capital')
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        end
        remaining_debt = @payment_remaining_debt.to_f
        @error_desc = []
        @projects = Project.where(id: @customer_credit.project_id)
        @project = @projects[0]
        if @project.blank?
          @error_desc.push("No existe un proyecto con el id: #{@customer_credit.project_id}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          @terms = Term.where(id: @project.term_id)
          @term = @terms[0]
          if @term.blank?
            @error_desc.push("No existe un plazo con el id: #{@project.term_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          else
            @payment_periods = PaymentPeriod.where(id: @project.payment_period_id)
            @payment_period = @payment_periods[0]
            if @payment_period.blank?
              @error_desc.push("No existe un periodo con el id: #{@project.payment_period_id}")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            end
          end
        end
        if remaining_debt.round.zero?
          @customer_credit.status = 'PA'
        else
          customer_credit_id = @customer_credit.id
          term = @term.value
          payment_period = @payment_period.value
          rate = (@project.client_rate.to_f / payment_period.to_f) / 100
          rate_with_iva = rate.to_f * 1.16
          payment_amount = @fixed_payment
          first_iteration = true
          last_payment = false
          until last_payment
            @current_payment += 1
            if first_iteration
              first_iteration = false
              interests = remaining_debt.to_f * rate.to_f
              iva = interests.to_f * 0.16
              capital = payment_amount.to_f - interests.to_f - iva.to_f
              if remaining_debt < capital
                capital = remaining_debt
                payment_amount = capital + interests.to_f + iva.to_f
                last_payment = true
              end
              current_debt = remaining_debt.to_f
              remaining_debt = current_debt.to_f - capital.to_f
              payment = capital.to_f + interests.to_f + iva.to_f
            else
              interests = remaining_debt.to_f * rate.to_f
              iva = interests.to_f * 0.16
              capital = payment_amount.to_f - interests.to_f - iva.to_f
              if remaining_debt < capital
                capital = remaining_debt
                payment_amount = capital + interests.to_f + iva.to_f
                last_payment = true
              end
              current_debt = remaining_debt.to_f
              remaining_debt = remaining_debt.to_f - capital.to_f
              payment = capital.to_f + interests.to_f + iva.to_f
            end
            number_of_periods = @current_payment - @max_num_payment
            case payment_period.to_s
            when '365'
              payment_date = @last_date + term.days
            when '12'
              payment_date = @last_date + number_of_periods.months
            when '1'
              payment_date = @last_date + number_of_periods.years
            when '6'
              payment_date = @last_date + (number_of_periods * 2).months
            when '4'
              payment_date = @last_date + (number_of_periods * 3).months
            else
              @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Dias(365), Meses(12), Años(1), Bimestres(6), Trimestres(4)")
              error_array!(@error_desc, :unprocessable_entity)
              raise ActiveRecord::Rollback
            end
            sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: @current_payment, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2), payment: payment.round(2),
                                                              capital: capital.round(2), interests: interests.round(2), iva: iva.round(2), payment_date: payment_date, status: 'PE')
            next unless sim_customer_payments.blank?

            @error_desc.push('Ocurrio un error al crear la simulación de los pagos del crédito')
            error_array!(@error_desc, unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        end
      end
      sum_capital = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.capital }
      sum_interests = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.interests }
      sum_iva = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.iva }
      total_debt = sum_capital + sum_interests + sum_iva
      @customer_credit.update(capital: sum_capital, interests: sum_interests, iva: sum_iva, total_debt: total_debt, restructure_term: @current_payment)
      if @customer_credit.save
        restructure_funder_yields_term
        simulation = params[:simulation]
        if simulation.blank? || simulation == 'false'
          @customer_credit
        else
          @customer_credit
          raise ActiveRecord::Rollback
        end
      else
        error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    end
  end

  def payment
    @error_desc = []
    ActiveRecord::Base.transaction do
      @customer_credits = CustomerCredit.where(id: restructure_credits_params[:customer_credit_id])
      @customer_credit = @customer_credits[0]
      if @customer_credit.blank?
        @error_desc.push("No existe un crédito con el id: #{restructure_credits_params[:customer_credit_id]}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        @fixed_payment = @customer_credit.fixed_payment
        customer_payment = @customer_credit.pending_payments.first
        if customer_payment.blank?
          @error_desc.push('No se encontraron pagos pendientes')
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          payment_capital = restructure_credits_params[:total_payment].to_f - customer_payment.interests.to_f - customer_payment.iva.to_f
          @current_payment_capital = payment_capital
          current_debt_total = customer_payment.current_debt.to_f + customer_payment.interests.to_f + customer_payment.iva.to_f
          if restructure_credits_params[:total_payment].to_f > current_debt_total.to_f.round(2)
            @error_desc.push("El pago no puede ser mayor al adeudo pendiente: #{current_debt_total.round(2)}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          elsif restructure_credits_params[:total_payment].to_f < @fixed_payment.to_f && current_debt_total.to_f.round(2) > @fixed_payment.to_f
            @error_desc.push("A menos que el resto del adeudo sea menor al pago fijo, el pago no puede ser menor al pago fijo: #{@fixed_payment}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          elsif restructure_credits_params[:total_payment].to_f < @fixed_payment.to_f && restructure_credits_params[:total_payment].to_f < current_debt_total.to_f.round(2)
            @error_desc.push("Si el adeudo restante es menor al pago fijo, se debe de pagar el total del adeudo restante: #{current_debt_total.to_f.round(2)}")
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          else
            @payment_remaining_debt = customer_payment.current_debt - payment_capital
            customer_payment.capital = payment_capital.round(2)
            customer_payment.payment = restructure_credits_params[:total_payment].to_f
            customer_payment.remaining_debt = @payment_remaining_debt.round(2)
            customer_payment.status = 'PA'
            customer_payment.extra1 = 'Se actualiza el pago con el abono a capital correspondiente'
            total_payments = @customer_credit.total_payments + restructure_credits_params[:total_payment].to_f
            @customer_credit.total_payments = total_payments
            @max_num_payment = customer_payment.pay_number
            @current_payment = customer_payment.pay_number
            @last_date = customer_payment.payment_date
          end
          if customer_payment.save
            @update_pending_payments_sql = "update sim_customer_payments set status=':new_status', extra1= ':comment' where customer_credit_id=':customer_credit_id' and status = ':current_status';"
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':new_status', 'CA'
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':comment',
                                                                             "Se cancela el pago por reestructuración en importe del pago, se abonó a capital: #{payment_capital.round(2)}"
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':customer_credit_id', @customer_credit.id.to_s
            @update_pending_payments_sql = @update_pending_payments_sql.gsub ':current_status', 'PE'
            @update_pending_payments = ActiveRecord::Base.connection.update(@update_pending_payments_sql)
          else
            @error_desc.push('No se pudo actualzar el pago actual con el abono a capital')
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        end
        @payment_amount = @customer_credit.fixed_payment
        remaining_debt = @payment_remaining_debt.to_f
        @error_desc = []
        @projects = Project.where(id: @customer_credit.project_id)
        @project = @projects[0]
        if @project.blank?
          @error_desc.push("No existe un proyecto con el id: #{@customer_credit.project_id}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          @terms = Term.where(id: @project.term_id)
          @term = @terms[0]
          if @term.blank?
            @error_desc.push("No existe un plazo con el id: #{@project.term_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          else
            @payment_periods = PaymentPeriod.where(id: @project.payment_period_id)
            @payment_period = @payment_periods[0]
            if @payment_period.blank?
              @error_desc.push("No existe un periodo con el id: #{@project.payment_period_id}")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            end
          end
        end
        if remaining_debt.round == 0
          @customer_credit.status = 'PA'
        else
          customer_credit_id = @customer_credit.id
          term = if @customer_credit.restructure_term.blank?
                   @term.value
                 else
                   @customer_credit.restructure_term
                 end
          payment_period = @payment_period.value
          rate = (@project.client_rate.to_f / payment_period.to_f) / 100
          rate_with_iva = rate.to_f * 1.16
          rest_term = term - @max_num_payment
          @payment_amount = (rate_with_iva.to_f * remaining_debt.to_f) / (1 - ((1 + rate_with_iva.to_f)**-rest_term.to_f))
          first_iteration = true
          1.upto(rest_term) do |_i|
            @current_payment += 1
            number_of_periods = @current_payment - @max_num_payment
            if first_iteration
              first_iteration = false
              interests = remaining_debt.to_f * rate.to_f
              iva = interests.to_f * 0.16
              capital = @payment_amount.to_f - interests.to_f - iva.to_f
              current_debt = remaining_debt.to_f
              remaining_debt = current_debt.to_f - capital.to_f
              payment = capital.to_f + interests.to_f + iva.to_f
            else
              interests = remaining_debt.to_f * rate.to_f
              iva = interests.to_f * 0.16
              capital = @payment_amount.to_f - interests.to_f - iva.to_f
              if remaining_debt < capital
                capital = remaining_debt
                @payment_amount = capital + interests.to_f + iva.to_f
                last_payment = true
              end
              current_debt = remaining_debt.to_f
              remaining_debt = remaining_debt.to_f - capital.to_f
              payment = capital.to_f + interests.to_f + iva.to_f
            end
            case payment_period.to_s
            when '365'
              payment_date = @last_date + rest_term.days
            when '12'
              payment_date = @last_date + number_of_periods.months
            when '1'
              payment_date = @last_date + number_of_periods.years
            when '6'
              payment_date = @last_date + (number_of_periods * 2).months
            when '4'
              payment_date = @last_date + (number_of_periods * 3).months
            else
              @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Dias(365), Meses(12), Años(1), Bimestres(6), Trimestres(4)")
              error_array!(@error_desc, :unprocessable_entity)
              raise ActiveRecord::Rollback
            end
            sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: @current_payment, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2), payment: payment.round(2),
                                                              capital: capital.round(2), interests: interests.round(2), iva: iva.round(2), payment_date: payment_date, status: 'PE')
            next unless sim_customer_payments.blank?

            @error_desc.push('Ocurrio un error al crear la simulación de los pagos del crédito')
            error_array!(@error_desc, unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        end
      end
      sum_capital = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.capital }
      sum_interests = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.interests }
      sum_iva = @customer_credit.current_payments.reduce(0) { |suma, current_payment| suma += current_payment.iva }
      total_debt = sum_capital + sum_interests + sum_iva
      @customer_credit.update(capital: sum_capital, interests: sum_interests, iva: sum_iva, total_debt: total_debt, fixed_payment: @payment_amount)
      if @customer_credit.save
        restructure_funder_yields_payment
        simulation = params[:simulation]
        if simulation.blank? || simulation == 'false'
          @customer_credit
        else
          @customer_credit
          raise ActiveRecord::Rollback
        end
      else
        error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def restructure_credits_params
    params.require(:restructure_credit).permit(:customer_credit_id, :total_payment)
  end

 

end

# simulation = params[:simulation]
# unless simulation.blank? || simulation == 'false'
#  render 'api/v1/requests/show'
#  raise ActiveRecord::Rollback
# else
#  request_mailer
#  render 'api/v1/requests/show'
# end
