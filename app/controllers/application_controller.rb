# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include ActionView::Helpers::AssetTagHelper
  
  include UserAuthentication
  # before_action :authenticate
  before_action :set_jbuilder_defaults
  before_action :set_mailer_defaults

  protected

  def authenticate
    token_str = params[:token]
    token = Token.find_by(token: token_str)

    if token.nil? || !token.is_valid? || !@my_app.is_your_token?(token)
      # render json: {error: "Tu Token es inv�lido" }, status: :unauthorized
      error!('Tu token es inválido ', :unauthorized)
    else
      @current_user = token.user
    end
  end

  def set_jbuilder_defaults
    @errors = []
  end

  def set_mailer_defaults
    @mailer_mode = GeneralParameter.get_general_parameter_value('MAILER_MODE')
    @mailer_test_email = GeneralParameter.get_general_parameter_value('MAILER_TEST_EMAIL')
  end

  def error!(message, status)
    @errors << message
    response.status = status
    render template: 'api/v1/errors'
  end

  def error_array!(array, status)
    @errors += array
    response.status = status
    render 'api/v1/errors'
  end

  def authenticate_owner(owner)
    if owner != @current_user
      render json: { errors: 'No tienes autorizado el editar este recurso' }, status: :unauthorized
      return false
    end
    true
  end

  def execute_statement(sql)
    results = ActiveRecord::Base.connection.execute(sql)

    results if results.present?
  end

  def create_customer_credit(total_requested, status, start_date, customer_id, term_id, payment_period_id, rate, iva_percent)
    @term_id = term_id
    @payment_period_id = payment_period_id
    @rate = rate
    @iva_percent = iva_percent
  
    @customer_credit = CustomerCredit.new(total_requested: total_requested, status: status, start_date: start_date, customer_id: customer_id, iva_percent: iva_percent)
    @capital = 0
    @customer_credit.capital = @capital
    @interests = 0
    @customer_credit.interests = @interests
    @iva = 0
    @customer_credit.iva = @iva
    @total_debt = 0
    @customer_credit.total_debt = @total_debt
    @total_payments = 0     
    @customer_credit.total_payments = @total_payment
    @fixed_payment = 0
    @customer_credit.fixed_payment = @fixed_payment      
    @end_date = @customer_credit.start_date
    @customer_credit.end_date = @end_date
    if @customer_credit.save              
      @terms = Term.where(id: term_id)
      @term = @terms[0]
      if @term.blank?
        @error_desc.push("No existe un plazo con el id: #{term_id}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        @payment_periods = PaymentPeriod.where(id: payment_period_id)
        @payment_period = @payment_periods[0]
        if @payment_period.blank?
          @error_desc.push("No existe un periodo con el id: #{payment_period_id}")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        end
      end      
      calculate_customer_payments
      @customer_credit.update(capital: @capital.round(2), interests: @interests.round(2), iva: @iva.round(2), total_debt: @total_debt.round(2), total_payments: @total_payments.round(2), end_date: @end_date, fixed_payment: @fixed_payment.round(2) )
      #render 'api/v1/customer_credits/show'
    else
      error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
      raise ActiveRecord::Rollback
    end
  end



  private

  # Calcula los pagos del cliente
  def calculate_customer_payments
    @error_desc = []
    customer_credit_id = @customer_credit.id
    iva_percent = @customer_credit.iva_percent
    term = @term.value
    payment_period = @payment_period.value
    total_requested = @customer_credit.total_requested
    rate = @customer_credit.rate
    rate_with_iva = rate.to_f * (1 + (iva_percent.to_f/100))
    start_date = @customer_credit.start_date
    payment_amount = (rate_with_iva.to_f * total_requested.to_f) / (1 - ((1 + rate_with_iva.to_f)**-term.to_f))
    @fixed_payment = payment_amount
    remaining_debt = 0
    1.upto(term) do |i|
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
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Meses(12), Meses(12), Quncenas(24), Semanas(52)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
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

  def send_control_desk_mailer(customer_credit)
    @customer_credit =  CustomerCredit.find(customer_credit)
    unless @customer_credit.blank?
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id
      FROM users u, roles r
      WHERE u.role_id = r.id
      AND r.name IN ('Mesa de control')"
    else
      error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
    end
    response = execute_statement(@query)
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      @mailer_signatories.each do |mailer_signatory|
        # begin
          # @token_control_desk =  SecureRandom.hex
          # TOKEN CON VIDA UTIL DE 7 DIAS
          # @token_control_desk_expiry = Time.now + 7.day
          # @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCredito/#{@token_control_desk}"
          # end while CustomerCredit.where(extra3: @token_control_desk).any?
        #PANTALLA EN EL FRONTEND PARA QUE MESA DE CONTROL VEA EL CREDITO, LO ANALICE Y LO APRUEBE/RECHACE
        @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.send_mail_committee(mail_to,
          mailer_signatory['name'],
          "Nomina GFC- #{mailer_signatory['name']} - El comité y la empresa han aceptado la propuesta de credito",
          # @current_user.name,
          "Aprobar como #{mailer_signatory['tipo']}",
          [@callback_url_committee,@customer_credit]
        ).deliver_now
      end
    end
  end

  def send_analyst_mailer(customer_credit)
    @customer_credit =  CustomerCredit.find(customer_credit)
    unless @customer_credit.blank?
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id
      FROM users u, roles r
      WHERE u.role_id = r.id
      AND r.name IN ('Analista')"
    else
      error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
    end
    response = execute_statement(@query)
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      @mailer_signatories.each do |mailer_signatory|
        # begin
          # @token_control_desk =  SecureRandom.hex
          # TOKEN CON VIDA UTIL DE 7 DIAS
          # @token_control_desk_expiry = Time.now + 7.day
          # @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCredito/#{@token_control_desk}"
          # end while CustomerCredit.where(extra3: @token_control_desk).any?
        #PANTALLA EN EL FRONTEND PARA QUE MESA DE CONTROL VEA EL CREDITO, LO ANALICE Y LO APRUEBE/RECHACE
        # @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        @callback_url_analyst = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.send_mail_committee(mail_to,
          mailer_signatory['name'],
          # "Nomina GFC- #{mailer_signatory['name']} - El comité y la empresa han aceptado la propuesta de credito",
          "Factor GFC Global - Credi Global - El comité y la empresa han aceptado la propuesta de credito - #{mailer_signatory['tipo']}",
          # @current_user.name,
          "Revisar como #{mailer_signatory['tipo']}",
          [@callback_url_analyst,@customer_credit]
        ).deliver_now
      end
    end
  end

  def send_committee_mail(customer_credit)
    @customer_credit = customer_credit
    unless @customer_credit.blank?
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id
      FROM users u, roles r
      WHERE u.role_id = r.id
      AND r.name IN ('Analista', 'Comité','Empresa')"
    else
      error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
    end
    response = execute_statement(@query)
    unless response.blank?
      @cliente = Customer.find(@customer_credit.customer_id)
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      @mailer_signatories.each do |mailer_signatory|
        begin
          @token_commitee =  SecureRandom.hex
          # TOKEN CON VIDA UTIL DE 7 DIAS
          @token_commitee_expiry = Time.now + 7.day
          #VISTA EN EL FRONTEND PARA QUE EL COMITE VEA EL CREDITO/EMPRESA, LO ANALICE Y LO APRUEBE/RECHACE(SI MANDAR UN TOKEN PARA QUE EL COMITE/EMPRESA TENGA CIERTO TIEMPO PARA DAR DICTAMEN)
          @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCredito/#{@token_commitee}"
        end while CustomerCredit.where(extra3: @token_commitee).any?
        #CREA UN REGISTRO EN CUSTOMERCREDITSIGNATORIES
        @customer_credit_signatory = CustomerCreditsSignatory.new(status: @customer_credit.status,customer_credit_id: @customer_credit.id,user_id: mailer_signatory['id'], signatory_token: @token_commitee, signatory_token_expiration: @token_commitee_expiry)
        if @customer_credit_signatory.save
        else 
          error_array!(@customer_credit_signatory.errors.full_messages, :unprocessable_entity)
          raise ActiveRecord::Rollback
        end
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.send_mail_committee(mail_to,
          mailer_signatory['name'],
          # "Facot GFC Global - Credi Global - #{mailer_signatory['name']} - Favor de aprovar o rechazar propuesta de credito",
          "Factor GFC Global - Credi Global - Solicitud de aprobación de Crédito - #{mailer_signatory['tipo']}",
          # @current_user.name,
          "Aprobar como #{mailer_signatory['tipo']}",
          [@callback_url_committee,@customer_credit,@cliente.name]
        ).deliver_now
      end
    end
  end

  def mailer_mode_to (email)
    if @mailer_mode == 'TEST'
      @mailer_mail_to = @mailer_test_email
    else
      @mailer_mail_to = email
    end
    @mailer_mail_to
  end

end

