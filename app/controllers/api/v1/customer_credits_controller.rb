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
    ActiveRecord::Base.transaction do
      @error_desc = []
      @customer_credit = CustomerCredit.new(customer_credits_params)
      @respuesta = Customer.where(id: @customer_credit.customer_id)
      @customer = @respuesta[0]
      if @customer.blank?
        error_array!(@error_desc, :unprocessable_entity)
        @error_desc.push("No existe el @customer: #{@customer_credit.customer_id}")
        raise ActiveRecord::Rollback
      else
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
        @payment_amount = params[:payment_amount]
        @customer_credit.fixed_payment = @fixed_payment
        @customer_credit.balance = 1
        @anuality_date = params[:anuality_date]
        @anuality = params[:anuality]
        @end_date = @customer_credit.start_date
        @customer_credit.end_date = @end_date
        if @customer_credit.save  
          @payment_periods = PaymentPeriod.where(key: @customer.salary_period)
          @payment_period = @payment_periods[0]
          if @payment_period.blank?
            @error_desc.push("No existe un periodo con el id: #{@customer_credit.payment_period_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end 
          @salary = @customer.salary.to_f
          @total_requested = @customer_credit.total_requested.to_f
          if(@total_requested > (@salary.to_f * @payment_period.value.to_f))
            @error_desc.push("El total del credito no puede ser mayor a un año de sueldo del empleado")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
                  
            @terms = Term.where(id: @customer_credit.term_id)
            @term = @terms[0]
          if @term.blank?
            term = 0
          else
            term = @term.value
          end
            calculate_customer_payment(term,@payment_amount,@anuality,@anuality_date)
            @customer_credit.update(capital: @capital.round(2), interests: @interests.round(2), iva: @iva.round(2), total_debt: @total_debt.round(2), total_payments: @total_payments.round(2),
                                  end_date: @end_date, fixed_payment: @fixed_payment.round(2))
          if @customer_credit.status == 'SI'
                render 'api/v1/customer_credits/show'
                raise ActiveRecord::Rollback
          elsif @customer_credit.status == 'PR'
                #METODO QUE VA A MANDARLE UN CORREO AL PERSONAL DEL COMITE Y DE FACTOR PARA QUE APRUEBEN EL CREDITO PROPUESTO PARA EL CLIENTE
                send_committee_mail(@customer_credit)
          else
              render 'api/v1/customer_credits/show' 
          end
        else
          error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
          raise ActiveRecord::Rollback
        end
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
                                            :customer_id, :term_id, :currency , :user_id )
  end


  def calculate_customer_payment(term,payment_amount,anuality,anuality_date)
    @error_desc = []
    customer_credit_id = @customer_credit.id
    iva_percent = @customer_credit.iva_percent
    date = @customer_credit.start_date
    @dias_dispersion = params[:dias_dispersion]
    payment_period = @payment_period.value
    total_requested = @customer_credit.total_requested
    client_rate = @customer_credit.rate
    rate = (client_rate.to_f / payment_period.to_f) / 100
    diary_rate = ((client_rate.to_f/100) / 360)
    rate_with_iva = rate.to_f * (1 + (iva_percent.to_f/100))
    #Si payment_amount viene vacio se calcula el pago, si no se calcula el plazo
    if payment_amount.blank? && term == 0
      @error_desc.push("Se debe de mandar el pago o el plazo")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
    else
      if payment_amount.blank?
        payment_amount = (rate_with_iva.to_f * total_requested.to_f) / (1 - ((1 + (rate_with_iva.to_f)) ** (-term.to_f)))
      elsif term == 0
        term = ((Math.log (1/(1-((rate_with_iva.to_f * total_requested.to_f) / payment_amount.to_f)))) / (Math.log (1 + rate_with_iva.to_f))).ceil
      end 
    end 
    @fixed_payment = payment_amount.to_f
    @commision = (total_requested.to_f * 0.01) * (1 + (iva_percent.to_f/100))
    remaining_debt = 0
    actual_date = DateTime.now
    @number_anuality = []
    start_date = actual_date + @dias_dispersion.to_i.days
    start_date += 1 until start_date.strftime('%u').to_i == 4
    1.upto(term) do |i|
      #Se revisa si Los periodos de pagos deben de ser mensuales, quincenales o semanales
      case payment_period.to_s
      when '12'
        payment_date = start_date + i.months
      when '52'
        payment_date = start_date + (i/4).months
      when '24' #pagos por quincenas
        #Se valida si es el primer pago del credito
        #La fecha del primer pago va a sera al inicio del periodo siguiente a partir de la fecha actual mas los dias configurados en el parametro
        if i == 1
         #Si la fecha es menor o igual a 15 el primer pago sera el dia ultimo del mes, si no el pago sera el dia 15 del siguiente mes
          if (start_date.day <= 15)
            payment_date = start_date.end_of_month 
          else
            payment_date = DateTime.new(start_date.year, start_date.next_month.month, 15)
          end
          #Si no es el primer pago se revisa en que fecha estamos
        else
          #Si el dia es 15 el pago es el fin de mes
          if (start_date.day == 15)
            payment_date  = start_date.end_of_month 
            #Si no el dia de pago es el 15 del siguiente mes
          else
            #Se revisa si es diciembre (12) para cambiar de año
            if (start_date.month == 12)
              payment_date = DateTime.new(start_date.year + 1, start_date.next_month.month, 15) 
            else
              payment_date = DateTime.new(start_date.year, start_date.next_month.month, 15) 
            end
          end
        end
      else
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Meses(12), Quincenas(24), Semanas(52)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end

      if i == 1
        interests = total_requested.to_f * rate.to_f
        iva = interests.to_f * (iva_percent.to_f/ 100)
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = total_requested.to_f
        remaining_debt = total_requested.to_f - capital.to_f
        payment = capital.to_f + interests.to_f + iva.to_f
      else
        interests = remaining_debt.to_f * rate.to_f
        iva = interests.to_f * (iva_percent.to_f / 100)
        current_debt = remaining_debt.to_f
        if i == term
          payment = current_debt.to_f + interests.to_f + iva.to_f
          capital = payment.to_f - interests.to_f - iva.to_f
        elsif @anuality.present? && anuality_date.present?
          #Se guardan numeros de pagos cuando debe de ser la anualidad
          if (payment_date.month == anuality_date.to_i && payment_date.day == 15) 
            @number_anuality.push i 
          end
          max_anuality = total_requested * 0.10
          if @anuality.to_f > max_anuality.to_f
            @error_desc.push('La anualidad no puede ser mayor al 10% del credito')
            error_array!(@error_desc, :unprocessable_entity)
            raise ActiveRecord::Rollback
          else

            if @number_anuality.include?(i)
              payment = @anuality.to_f
              capital = payment.to_f - interests.to_f - iva.to_f
             # term = ((Math.log (1/(1-((rate_with_iva.to_f * remaining_debt.to_f) / payment_amount.to_f)))) / (Math.log (1 + rate_with_iva.to_f))).ceil
            else
              puts'remaining_debt' + remaining_debt.inspect
            
              capital = payment_amount.to_f - interests.to_f - iva.to_f
              payment = capital.to_f + interests.to_f + iva.to_f
            end
          end
        else
          capital = payment_amount.to_f - interests.to_f - iva.to_f
          payment = capital.to_f + interests.to_f + iva.to_f
        end
        remaining_debt = remaining_debt.to_f - capital.to_f
        if(remaining_debt < 0)
          payment = current_debt.to_f + interests.to_f + iva.to_f
          capital = payment.to_f - interests.to_f - iva.to_f
          #break
        end
      end
      @capital += capital
      @interests += interests
      @iva += iva
      sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: i, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2),
                                                        payment: payment.round(2),
                                                        capital: capital.round(2), interests: interests.round(2), iva: iva.round(2), payment_date: payment_date, status: 'PE')
      
      if sim_customer_payments.blank?
        @error_desc.push('Ocurrio un error al crear la simulación de los pagos del crédito')
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      start_date = payment_date
      @end_date = payment_date
      break if (remaining_debt.to_f < 0)
    end
    @total_debt = @total_debt + @capital + @interests + @iva
  end

  # TO DO: MOVER ESTE METODO AL PUNTO DONDE COMITÉ Y EMPRESA ACEPTA EL CREDITO PARA NOTIFICAR AL CLIENTE Y ESTE LO ACEPTE.
  def customer_credit_mailer
    unless @customer_credit.blank?
      @query = 
      "SELECT (peo.first_name||' ' ||peo.last_name||' '||peo.second_last_name )as name, peo.rfc, peo.email
        FROM contributors con, people peo, customers cus
        WHERE con.person_id = peo.id
        AND cus.contributor_id = con.id
        AND cus.id = ':customer_id'"
      @query = @query.gsub ':customer_id', @customer_credit.customer_id.to_s
    else
      @query = 
      "SELECT (peo.first_name||' ' ||peo.last_name||' '||peo.second_last_name name), peo.rfc, peo.email
        FROM contributors con, people peo, customers cus
        WHERE con.person_id = peo.id
        AND cus.contributor_id = con.id
        AND cus.id = ':customer_id'"
      @query = @query.gsub ':customer_id', @customer_credit.customer_id.to_s
    end  
    response = execute_statement(@query)
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      begin
        @token = token
        @token_expiry = Time.now + 1.day
        @callback_url_aceptado = "#{@frontend_url}/#/get_callback/#{@token}/aceptado"
        @callback_url_rechazado = "#{@frontend_url}/#/get_callback/#{@token}/rechazado"
      end while CustomerCredit.where(extra3: @token).any?
      @customer_credit.update(extra3: @token)
      @customer_credit.update(extra2: @token_expiry)
       # correo para el cliente
       #email, name, subject, supplier, company, invoices, signatories, request, create_user, max_days, limit_days, year_base_days, final_rate
      @mailer_signatories.each do |mailer_signatory|
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.send_mail_credit(mail_to,
          mailer_signatory['name'],
          "Nomina GFC - Confirmar propuesta de credito",
          # @current_user.name,
          "Hola",
          [@callback_url_aceptado,@callback_url_rechazado,@customer_credit]
        ).deliver_now
      end
    end
  end

  def token
    SecureRandom.hex
  end

end