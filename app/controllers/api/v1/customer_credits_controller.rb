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
      @companies = Company.where(id: @customer.company_id)
      @company = @companies[0]
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
        #@company_segment.credit_limit = 0
        @customer_credit.fixed_payment = @fixed_payment
        @customer_credit.balance = 1
        @anuality_date = params[:anuality_date]
        @anuality = params[:anuality]
        @end_date = @customer_credit.start_date
        @customer_credit.end_date = @end_date
        if @customer_credit.rate.blank?
          @rate = 0
          @customer_credit.rate = @rate
        end
        if @customer_credit.save  
          @payment_periods = PaymentPeriod.where(key: @customer.salary_period)
          @payment_period = @payment_periods[0]
          if @payment_period.blank?
            @error_desc.push("No existe un periodo con el id1: #{@customer_credit.payment_period_id}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end 
          @user_id = @customer_credit.user_id
          if @user_id.blank?
            @error_desc.push("Se debe de mandar el usuario firmado")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end 
          if @customer.extra3.nil?
              @company_segments = CompanySegment.where(company_id: @company.id)
              elements = @company_segments.length
              if elements == 1
                @company_segment = @company_segments[0]
              else
                seniority = @customer.seniority
                unless seniority.blank?
                 if seniority < 4
                  @company_segments = CompanySegment.where(company_id: @company.id, key: 4)
                  @company_segment = @company_segments[0]
                 elsif seniority >= 4 && seniority < 9
                  @company_segments = CompanySegment.where(company_id: @company.id, key: 9)
                  @company_segment = @company_segments[0]
                 else seniority >= 9
                  @company_segments = CompanySegment.where(company_id: @company.id, key: 99)
                  @company_segment = @company_segments[0]
                 end
                else
                 @error_desc.push("Cliente no tiene capturada su antiguedad")
                    error_array!(@error_desc, :not_found)
                    raise ActiveRecord::Rollback
                end
              end
              
          else
            @company_segments = CompanySegment.where(company_id: @company.id, key: @customer.extra3)
            @company_segment = @company_segments[0]  
          end
          @salary = @customer.salary.to_f
          @total_requested = @customer_credit.total_requested.to_f
          @anual_salary = @salary.to_f * @payment_period.value.to_f
          if(@total_requested > ((@company_segment.credit_limit.to_f * @anual_salary.to_f)/12))
            @error_desc.push("El total del credito no puede ser mayor #{@company_segment.credit_limit.to_f} meses de sueldo del empleado")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end      
            @terms = Term.where(id: @customer_credit.term_id)
            @term = @terms[0]
          if @term.blank?
            term = 0
          else
            term = @term.value
            max_period = (@company_segment.max_period.to_f * @payment_period.value.to_f)
            if  (term > max_period)
            @error_desc.push("El numero de pagos no puede ser mayor a #{@company_segment.max_period} años , seleccionar otro plazo")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end   
        end
            calculate_customer_payment(term,@payment_amount,@anuality,@anuality_date)
            @months = (@end_date.year * 12 + @end_date.month) - (@date.year * 12 + @date.month)
           
            @debt_time = (@months.to_f/12)
            @insurance_percent = GeneralParameter.get_general_parameter_value('SEGURO')
            total_requested = @customer_credit.total_requested
            iva_percent = @customer_credit.iva_percent
            @insurance = total_requested.to_f * @debt_time * (1+(iva_percent/100)) * @insurance_percent.to_f
            if @new_term.blank?
              @new_term_id = @customer_credit.term_id
            end
            @customer_credit.update(capital: @capital.round(2), interests: @interests.round(2), iva: @iva.round(2), total_debt: @total_debt.round(2), total_payments: @total_payments.round(2),
                                  end_date: @end_date, fixed_payment: @fixed_payment.round(2), commission1: @commission.round(2), payment_period_id: @payment_period.id, start_date: @date, 
                                  debt_time: @debt_time.round(2), insurance1: @insurance.round(2), term_id: @new_term_id)
          if @customer_credit.status == 'SI' # SI = SIMULAR
                render 'api/v1/customer_credits/show'
                raise ActiveRecord::Rollback
          elsif @customer_credit.status == 'PR' #PR = PROPUESTO
            # MANDA CORREO AL CLIENTE PARA QUE LO APRUEBE
                customer_credit_mailer
                render 'api/v1/customer_credits/show'
          elsif @customer_credit.status == 'PA' #PA = POR APROBAR
                if documents_mode
                  generate_customer_credit_request_report_pdf
                end
                # CREA SIGNATORIES
                create_credit_signatories
                # METODO QUE VA A MANDARLE UN CORREO A TESORERIA PARA QUE DE DE ALTA LA CUENTA BANCARIA DEL EMPLEADO(CLIENTE)
                send_treasury_client_bank_account_mail(@customer_credit)
                render 'api/v1/customer_credits/show'
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
    # VALIDA QUE VENGA DE STATUS PR Y CON EL CREDIT ID Y MANDE EL MAILER AL CLIENTE.
    @customer_credit.update(customer_credits_params)
    #  MAILER AL CLIENTE PARA ACEPTAR O RECHAZAR CREDITO.    
    if customer_credits_params['status'] == 'PR'
      customer_credit_mailer
    end
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
                                            :rate, :debt_time, :destination, :amount_allowed, :time_allowed, :iva_percent,
                                            :customer_id, :term_id, :currency, :user_id, :extra3, :job, :credit_number )
  end


  def calculate_customer_payment(term,payment_amount,anuality,anuality_date)
    @error_desc = []
    customer_credit_id = @customer_credit.id
    iva_percent = @customer_credit.iva_percent
    date = @customer_credit.start_date
    payment_period = @payment_period.value
    total_requested = @customer_credit.total_requested
    if @customer_credit.rate == 0
    @customer_credit.rate = @company_segment.company_rate
    @commission_per = @company_segment.commission
    else
       @new_rates = ExtRate.where(value: @customer_credit.rate)
       @new_rate = @new_rates[0]
       if @new_rate.blank?
         @new_rate = ExtRate.new(key: 'CUSTOM' , description: 'Taza creada por usurio', start_date: DateTime.now, value: @customer_credit.rate, rate_type: 'TAZA')
         unless @new_rate.save
          render json: { error: @rate.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
       end         
  end
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
        pay_min = (rate_with_iva.to_f * total_requested.to_f) / payment_amount.to_f
        if pay_min > 1 
          @error_desc.push("El numero de pagos no puede ser mayor a #{@company_segment.max_period} años, ingresar un pago mas alto")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          term = ((Math.log (1/(1-((rate_with_iva.to_f * total_requested.to_f) / payment_amount.to_f)))) / (Math.log (1 + rate_with_iva.to_f))).ceil
        end
        if term < (@payment_period.value.to_f * @company_segment.max_period)
          @new_terms = Term.where(value: term)
          @new_term = @new_terms[0]
          if @new_term.blank?
            @new_term = Term.new(key:term.to_s + ' pagos', description: 'Crédito', value: term, term_type: @customer.salary_period, credit_limit: '100000', extra1: 'CUSTOM'  )
            unless @new_term.save
              render json: { error: @term.errors }, status: :unprocessable_entity
              raise ActiveRecord::Rollback
          end
          @new_term_id = @new_term.id
        else
          @new_term_id = @new_term.id
        end
      else
        @error_desc.push("El numero de pagos no puede ser mayor a #{@company_segment.max_period} años, ingresar un pago mas alto")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
      end
      end 
    end 
    @fixed_payment = payment_amount.to_f
    @commission = (total_requested.to_f * @commission_per.to_f/100) * (1 + (iva_percent.to_f/100))
    remaining_debt = 0
    actual_date = DateTime.now
    @number_anuality = []
    @dias_dispersion = GeneralParameter.get_general_parameter_value('DIAS_DISPERSION')     
    @date = actual_date + @dias_dispersion.to_i
    @pay_date = GeneralParameter.get_general_parameter_value('DIA_PAGO')
    @pay_number = @company_segment.extra1
  
    if @pay_date == 0
      @error_desc.push("No existe el parametro general DIA PAGO")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    else
        @date += 1 until @date.strftime('%u').to_i == @pay_date.to_i
      end
    start_date = @date
    1.upto(term) do |i|
      #Se revisa si Los periodos de pagos deben de ser mensuales, quincenales o semanales
      case payment_period.to_s
      when '12'
        @payment_date = start_date + i.months
      when '52'
         if i == 1
          #Si es el primer pago a partir de la fecha de inicio (start_date) se deja pasar un periodo y luego se paga
          #al siguiente dia configurado en el campo extra 3 de company_segments
           finish_date = start_date + 7.day
           finish_date += 1 until finish_date.strftime('%u').to_i == @pay_number.to_i
           @payment_date = finish_date 
         else
          #si no es el primer pago se paga cada miercoles una vez por semana
          start_date = @payment_date
          @payment_date = start_date + 7.day
        end
      when '24' #pagos por quincenas
        #Se valida si es el primer pago del credito
        #La fecha del primer pago va a sera al inicio del periodo siguiente a partir de la fecha actual mas los dias configurados en el parametro
        if i == 1
         #Si la fecha es menor o igual a 15 el primer pago sera el dia ultimo del mes, si no el pago sera el dia 15 del siguiente mes
          if (start_date.day <= 15)
            @payment_date = start_date.end_of_month 
          else
            if (start_date.month == 12)
              @payment_date = DateTime.new(start_date.year + 1, start_date.next_month.month, 15) 
            else
              @payment_date = DateTime.new(start_date.year, start_date.next_month.month, 15) 
            end
          end
          #Si no es el primer pago se revisa en que fecha estamos
        else
          #Si el dia es 15 el pago es el fin de mes
          if (start_date.day == 15)
            @payment_date  = start_date.end_of_month 
            #Si no el dia de pago es el 15 del siguiente mes
          else
            #Se revisa si es diciembre (12) para cambiar de año
            if (start_date.month == 12)
              @payment_date = DateTime.new(start_date.year + 1, start_date.next_month.month, 15) 
            else
              @payment_date = DateTime.new(start_date.year, start_date.next_month.month, 15) 
            end
          end
        end
      else
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Meses(12), Quincenas(24), Semanas(52)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end

      if i == 1
        distance_in_days = distance_of_time_in_days(start_date,@payment_date,false)
        interests = total_requested.to_f * (diary_rate.to_f * distance_in_days.to_f)
        iva = interests.to_f * (iva_percent.to_f/ 100)
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = total_requested.to_f
        remaining_debt = total_requested.to_f - capital.to_f
        payment = capital.to_f + interests.to_f + iva.to_f
      else
        distance_in_days = distance_of_time_in_days(start_date,@payment_date,false)
        interests = remaining_debt.to_f * (diary_rate.to_f * distance_in_days.to_f)
        iva = interests.to_f * (iva_percent.to_f / 100)
        current_debt = remaining_debt.to_f
        if i == term
          payment = current_debt.to_f + interests.to_f + iva.to_f
          capital = payment.to_f - interests.to_f - iva.to_f
        elsif @anuality.present? && anuality_date.present?
          #Se guardan numeros de pagos cuando debe de ser la anualidad
          if (@payment_date.month == anuality_date.to_i && @payment_date.day == 15) 
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
            else
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
        @i == i
      end
      @capital += capital
      @interests += interests
      @iva += iva
      sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: i, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2),
                                                        payment: payment.round(2),
                                                        capital: capital.round(2), interests: interests.round(2), iva: iva.round(2), payment_date: @payment_date, status: 'PE')
      
      if sim_customer_payments.blank?
        @error_desc.push('Ocurrio un error al crear la simulación de los pagos del crédito')
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      start_date = @payment_date
      @end_date = @payment_date
      break if (remaining_debt.to_f < 0)
    end
    @total_debt = @total_debt + @capital + @interests + @iva
    @total_payemnts = @i
  end

  # DIRECTOR Y EMPRESA ACEPTA EL CREDITO PARA NOTIFICAR AL CLIENTE Y ESTE LO ACEPTE.
  def customer_credit_mailer
    unless @customer_credit.blank?
      @query = 
      "SELECT (peo.first_name||' ' ||peo.last_name||' '||peo.second_last_name )as name, peo.rfc, peo.email,  peo.extra1
        FROM contributors con, people peo, customers cus
        WHERE con.person_id = peo.id
        AND cus.contributor_id = con.id
        AND cus.id = ':customer_id'"
      @query = @query.gsub ':customer_id', @customer_credit.customer_id.to_s
    else
      @query = 
      "SELECT (peo.first_name||' ' ||peo.last_name||' '||peo.second_last_name name), peo.rfc, peo.email, peo.extra1
        FROM contributors con, people peo, customers cus
        WHERE con.person_id = peo.id
        AND cus.contributor_id = con.id
        AND cus.id = ':customer_id'"
      @query = @query.gsub ':customer_id', @customer_credit.customer_id.to_s
    end  
    response = execute_statement(@query)
    unless response.blank?
      @term = Term.find_by_id(@customer_credit.term_id)
      unless @term.nil?
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
        # Correo para el cliente
        #email, name, subject, supplier, company, invoices, signatories, request, create_user, max_days, limit_days, year_base_days, final_rate
          # MANDA EL PDF COMPLETO AL CORREO
        @mailer_signatories.each do |mailer_signatory|
          mail_to = mailer_mode_to(mailer_signatory['email'])
          @customer_credit.update(attached: mailer_signatory['extra1'])
          URI.open('document.pdf', "wb") do |cd_file|      
            cd_file.write open(mailer_signatory['extra1'], "User-Agent"=> "Ruby/#{RUBY_VERSION}").read
          end
          # @file = CombinePDF.new
          @file = Rails.root.join('document.pdf')
          #email, name, subject, title, content
          SendMailMailer.send_mail_credit(mail_to,
            mailer_signatory['name'],
            "Nomina GFC - Confirmar propuesta de credito",
            # @current_user.name,
            "Hola",
            @file,
            [@callback_url_aceptado,@callback_url_rechazado,@customer_credit],
            @term[:key]
          ).deliver_now
          # ELIMINA PDF DE LOCAL
            File.delete(Rails.root.join("document.pdf"))if File.exist?(Rails.root.join("document.pdf"))
        end
      else
        @error_desc.push("No se encontró el plazo")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    else
      @error_desc.push("No se encontraron datos del credito")
      error_array!(@error_desc, :unprocessable_entity)
      raise ActiveRecord::Rollback
    end
  end

  def token
    SecureRandom.hex
  end

  def terms_params
    params.require(:term).permit(:key, :description, :value, :term_type, :credit_limit)
  end

  def create_credit_signatories
    #NOMINA
    @query_nomina = 
    "SELECT u.email as email,u.name as name,r.name as tipo, u.id
    FROM users u, roles r
    WHERE u.role_id = r.id
    AND r.name IN ('Comité','Empresa','Director')"

    #NOMINA ALSUPER
    @query_alsuper = 
    "SELECT u.email as email,u.name as name,r.name as tipo, u.id
    FROM users u, roles r
    WHERE u.role_id = r.id
    AND r.name IN ('Empresa','Director')"

    if GeneralParameter.where(key: 'ALSUPER_MODE')
      @query = @query_alsuper 
    else
      @query = @query_nomina
    end

    response = execute_statement(@query)
    # ESTA CONDICION DEBE SER UNLESS CUANDO NO HAGA PRUEBAS
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.where(key: 'FRONTEND_URL')
      unless @frontend_url.blank?
        begin
          @mailer_signatories.each do |mailer_signatory|
            @token_commitee =  validated_token_signatory
            # TOKEN CON VIDA UTIL DE 7 DIAS
            @token_commitee_expiry = Time.now + 7.day
            #VISTA EN EL FRONTEND PARA QUE EL COMITE VEA EL CREDITO/EMPRESA, LO ANALICE Y LO APRUEBE/RECHACE(SI MANDAR UN TOKEN PARA QUE EL COMITE/EMPRESA TENGA CIERTO TIEMPO PARA DAR DICTAMEN)
            @callback_url_committee = "#{@frontend_url}/#/aprobarCredito/#{@token_commitee}"
            #CREA UN REGISTRO EN CUSTOMERCREDITSIGNATORIES
            customer_credit_signatory = CustomerCreditsSignatory.create(customer_credit_id: @customer_credit.id, signatory_token: @token_commitee, signatory_token_expiration: @token_commitee_expiry,status: 'PE',user_id: mailer_signatory['id'])
            if customer_credit_signatory.blank?
              @error_desc.push("No se pudieron generar las firmas")
                  error_array!(@error_desc, :not_found)
                  raise ActiveRecord::Rollback
            end
          end
        rescue Errno::ENOENT
          p "File not found"
          @error_desc.push("Hubo un error al tratar de generar los firmantes")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        else
          p "File saved"
        end
      else
        # error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
        @error_desc.push("No se encontró parametro general FRONTEND_URL")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    else
      # error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
      @error_desc.push("No se encontraron Analistas,Empresa o Comité asignados")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
  end

  def validated_token_signatory
    token =  SecureRandom.hex
    while CustomerCreditsSignatory.where(signatory_token: token).any?
      token =  SecureRandom.hex
    end
    return token
  end

  def distance_of_time_in_days(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_days = (((to_time - from_time).abs)/86400).round
    return distance_in_days
  end

end