# frozen_string_literal: true
require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require 'json'
require 'combine_pdf'
require 'open-uri'

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
      error!('Tu token es inválido', :unauthorized)
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
          @error_desc.push("No existe un periodo con el id2: #{payment_period_id}")
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
    @customer_credit =  CustomerCredit.find_by_id(customer_credit)
    unless @customer_credit.blank?
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id as user_id
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
      # ASIGNA EL CREDITO A MESA DE CONTROL CON UN UPDATE
      @customer_credit.update(user_id: mailer_signatory['user_id'])
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
        SendMailMailer.committee(mail_to,
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
    @customer_credit =  CustomerCredit.find_by_id(customer_credit)
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
        #PANTALLA EN EL FRONTEND PARA QUE FIRMANTES VEAN EL CREDITO, LO ANALICE Y LO APRUEBE/RECHACE
        # @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        @callback_url_analyst = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.commitee(mail_to,
          mailer_signatory['name'],
          "Factor GFC Global - Credi Global - Revisar Crédito - #{mailer_signatory['tipo']}",
          "Revisar como #{mailer_signatory['tipo']}",
          [@callback_url_analyst,@customer_credit]
        ).deliver_now
      end
    end
  end

  def send_analyst_mailer1(customer_credit)
    @customer_credit =  CustomerCredit.find_by_id(customer_credit)
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
        #PANTALLA EN EL FRONTEND PARA QUE ANALISTA VEA EL CREDITO, LO ANALICE Y LO APRUEBE/RECHACE
        # @callback_url_committee = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        @callback_url_analyst = "#{@frontend_url}/#/panelcontrol/aprobarCreditos"
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.analyst1(mail_to,
          mailer_signatory['name'],
          "Factor GFC Global - Credi Global - Direccion, comité y la empresa han aceptado la propuesta de credito - #{mailer_signatory['tipo']}",
          "Revisar como #{mailer_signatory['tipo']}",
          [@callback_url_analyst,@customer_credit]
        ).deliver_now
      end
    end
  end

  def send_customer_nip_mailer(customer)
    @customer =  Customer.find_by_id(customer.id)
    unless @customer.blank?
      @query = 
      "SELECT u.email as email,u.name as name, u.id
      FROM users u
      WHERE u.id = ':user_id';"
      @query = @query.gsub ':user_id', @customer.user_id.to_s
    else
      error_array!(@customer.errors.full_messages, :unprocessable_entity)
    end
    response = execute_statement(@query)
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      @mailer_signatories.each do |mailer_signatory|
        begin
          @token_nip =  SecureRandom.hex(5)
          # TOKEN CON VIDA UTIL DE 1 DIA
          @token_nip_expiry = Time.now + 1.day
        end while Customer.where(extra1: @token_nip).any?
        @customer.update(extra1: @token_nip, extra2: @token_nip_expiry)
        mail_to = mailer_mode_to(mailer_signatory['email'])
        # email, name, subject, title, content
        SendMailMailer.customer_nip(mail_to,
          mailer_signatory['name'],
          "Factor Global GFC - Nómina Personal - Validación de Código NIP - Cliente",
          "CÓDIGO DE VERIFICACIÓN",
          @token_nip
        ).deliver_now
      end
    end
  end
  
  def send_treasury_client_bank_account_mail(customer_credit)
    @customer_credit = customer_credit
    # unless @customer_credit.blank?
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id
      FROM users u, roles r
      WHERE u.role_id = r.id
      AND r.name IN ('Tesorería')"
      response = execute_statement(@query)
      # ESTA CONDICION DEBE SER UNLESS CUANDO NO HAGA PRUEBAS
      unless response.blank?
        @cliente = Customer.find_by_id(@customer_credit.customer_id)
        unless @cliente.blank?
          @contributor = Contributor.find_by_id(@customer.contributor_id)
          unless @contributor.blank?
            @mailers = response.to_a
              @mailers.each do |mailer|
                  mail_to = mailer_mode_to(mailer['email'])
                  SendMailMailer.tesoreria(mail_to,
                  mailer['name'],
                    "Factor GFC Global - Credi Global - Cuenta Bancaria de cliente - #{mailer['tipo']}",
                    "Datos para dar de alta cuenta bancaria del cliente",
                    [@contributor,@customer_credit,@cliente.name]
                  ).deliver_now
              end
          else
            # error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
            @error_desc.push("No se encontró contributor")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          end
        else
          # error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
          @error_desc.push("No se encontró cliente")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        end
      else
        # error_array!(@customer_credit.errors.full_messages, :unprocessable_entity)
        @error_desc.push("No se encontró usuario con rol de Tesorería")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
  end

  def send_signatory_mail(signatory)
    @error_desc = []
    @error_desc.push("send_signatory_mail")
    @signatory = signatory
    unless @signatory.blank?
      @usuario = User.find_by_id(@signatory.user_id)
      unless @usuario.blank?
        @customer_credit = CustomerCredit.find_by_id(@signatory.customer_credit_id)
        unless @customer_credit.blank?
          @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
          unless @frontend_url.blank?
            @cliente = Customer.find_by_id(@customer_credit.customer_id)
            unless @cliente.blank?
              @role = Role.find_by_id(@usuario.role_id)
              unless @role.blank?
                # signatory.each do |mailer_signatory|
                # begin
                  @signatory_token =  SecureRandom.hex
                  # TOKEN CON VIDA UTIL DE 7 DIAS
                  @signatory_token_expiry = Time.now + 7.day
                  #VISTA EN EL FRONTEND PARA QUE EL COMITE VEA EL CREDITO/EMPRESA, LO ANALICE Y LO APRUEBE/RECHACE(SI MANDAR UN TOKEN PARA QUE EL COMITE/EMPRESA TENGA CIERTO TIEMPO PARA DAR DICTAMEN)
                  @signatory.update(signatory_token: @signatory_token,signatory_token_expiration: @signatory_token_expiry)
                  @callback_url_committee = "#{@frontend_url}/#/aprobarCredito/#{@signatory_token}"
                # end while CustomerCreditsSignatory.where(signatory_token: @signatory_token).any?
                mail_to = mailer_mode_to(@usuario['email'])
                      SendMailMailer.committee(mail_to,
                        @usuario['name'],
                        "Factor GFC Global - Credi Global - Solicitud de aprobación de Crédito - #{@role['name']}",
                        "Aprobar como #{@role['name']}",
                        [@callback_url_committee,@customer_credit,@cliente.name]
                      ).deliver_now
                # end
              else
                @error_desc.push("No se encontró rol")
                error_array!(@error_desc, :not_found)
                raise ActiveRecord::Rollback
              end
            else
              @error_desc.push("No se encontró cliente")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            end
          else
          @error_desc.push("No se encontró parametro general FRONTEND_URL")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
          end  
        else
        @error_desc.push("No se encontró customer_credit")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
        end
      else
      @error_desc.push("No se encontró usuario")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
      end     
    else
      @error_desc.push("No se encontró la firma en signatories")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
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

  # CREA REPORTE PDF CON TODOS LAS VARIABLES DE SOLICITUD DE CREDITO Y GUARDA EN S3
  def generate_customer_credit_request_report_pdf
    # @mail_factor = 'sistemasfgfc@gmail.com'
    # @mail_factor = 'mescobedo@factorgfc.com'
    @error_desc = []
    @mail_factor = GeneralParameter.get_general_parameter_value('CONTACT_MAIL')
    @folio = @customer_credit.credit_folio
    @credit_number = @customer_credit.credit_number
    @lugar = 'Chihuahua, Chihuahua'
    @date = Time.now.strftime("%d/%m/%Y")
    @dia = Time.now.strftime("%d")
    @mes = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Noviembre", "December" => "Diciembre" }.fetch(Date.today.strftime("%B"))
    @anio = Time.now.strftime("%Y")
    @credit_analysis = CreditAnalysis.where(customer_credit_id: @customer_credit.id)
    unless @credit_analysis.blank?
      @customer_credit_data = CustomerCredit.get_customer_credit_data(@customer_credit.id)
      unless @customer_credit_data.blank?
        # @suburb_type = @customer_credit_data[0][""]
        @pagos_fijos = @customer_credit.fixed_payment
        @salario = @customer_credit_data[0]["salario"]
        @plazo_type = @customer_credit_data[0]["plazo_type"]   
        @term = @customer_credit_data[0]["numero_pagos"]
        if @plazo_type == 'Semanal'
          @plazo_term = @term.to_s + ' Semanas'
          @cantidad_pagos_al_mes = '5 MOVIMIENTOS'
          @pago_mas_alto = @pagos_fijos * 5
          @salario2 = @salario.to_f * 4.33
        elsif @plazo_type == 'Quincenal'
          @cantidad_pagos_al_mes = '2 MOVIMIENTOS'
          @pago_mas_alto = @pagos_fijos * 2
          @salario2 = @salario.to_f * 2
          @plazo_term = @term.to_s + ' Quincenas'
        end
        @puesto = @customer_credit_data[0]["puesto"]
        @plazo = @customer_credit_data[0]["plazo"]   
        @plazo_key = @customer_credit_data[0]["plazo_key"] 
        @cuenta_bancaria = @customer_credit_data[0]["cuenta_bancaria"]
        @cuenta_clabe = @customer_credit_data[0]["cuenta_clabe"]
        @banco = @customer_credit_data[0]["banco"]
        @calle = @customer_credit_data[0]["calle"]
        @numero_exterior = @customer_credit_data[0]["numero_exterior"]
        @numero_apartamento = @customer_credit_data[0]["numero_apartamento"]
        @colonia = @customer_credit_data[0]["colonia"]
        @codigo_postal = @customer_credit_data[0]["codigo_postal"]      
        @estado = @customer_credit_data[0]["estado"]
        @country = @customer_credit_data[0]["pais"]
        @municipio = @customer_credit_data[0]["municipio"]
        @company = @customer_credit_data[0]["nombre_empresa"]
        @company_telefono = @customer_credit_data[0]["pm_telefono"]
        @public_charge = @customer_credit_data[0]["public_charge"]
        @public_charge_det = @customer_credit_data[0]["public_charge_det"]
        @relative_charge = @customer_credit_data[0]["relative_charge"]
        @relative_charge_det = @customer_credit_data[0]["relative_charge_det"]
        @other_income_detail = @customer_credit_data[0]["other_income_detail"]
        @benefit = @customer_credit_data[0]["benefit"]
        @benefit_detail = @customer_credit_data[0]["benefit_detail"]
        @responsible = @customer_credit_data[0]["responsible"]
        @responsible_detail = @customer_credit_data[0]["responsible_detail"]
        @company_contributor_id = @customer_credit_data[0]["company_contributor_id"]
        @fecha_inicio_labores = @customer_credit_data[0]["fecha_inicio_labores"]
        @giro_empresa = @customer_credit_data[0]["giro_empresa"]
        @cat = @customer_credit_data[0]["cat"]
        @otros_gastos = @customer_credit_data[0]["otros_gastos"]
        @hipoteca = @customer_credit_data[0]["hipoteca"]
        @credito_automovil = @customer_credit_data[0]["credito_automovil"]
        @pertenece = @customer_credit_data[0]["pertenece"]
        @total_gastos = @customer_credit_data[0]["total_gastos"]
        @frecuencia_de_pago = @customer_credit_data[0]["frecuencia_de_pago"]
        @ingreso_total = @customer_credit_data[0]["ingreso_total"]
        @otros_ingresos = @customer_credit_data[0]["otros_ingresos"]
        @jefe_inmediato = @customer_credit_data[0]["jefe_inmediato"]
        @regimen_fiscal = @customer_credit_data[0]["pm_regimen_fiscal"]
        @rfc = @customer_credit_data[0]["pf_rfc"]
        @curp =@customer_credit_data[0]["pf_curp"]
        @NSS = @customer_credit_data[0]["pf_numero_seguro_social"]
        @seguro = @customer_credit_data[0]["seguro"]
        @seguro_saldo_deudor = @seguro.to_f/1.16
        @nombre = @customer_credit_data[0]["nombre"]
        @apellido_paterno = @customer_credit_data[0]["apellido_paterno"]
        @apellido_materno = @customer_credit_data[0]["apellido_materno"]
        @sexo = @customer_credit_data[0]["pf_genero"]
        @nacionalidad = @customer_credit_data[0]["pf_nacionalidad"]
        @lugar_nacimiento = @customer_credit_data[0]["pf_lugar_nacimiento"]
        @fecha_nacimiento = @customer_credit_data[0]["pf_fecha_nacimiento"].to_date 
        @age = Date.today.year - @fecha_nacimiento.year
        @age -= 1 if Date.today < @fecha_nacimiento + @age.years #for days before birthday
        @estado_civil = @customer_credit_data[0]["pf_estado_civil"]
        @regimen_marital = @customer_credit_data[0]["pf_regimen_marital"]
        @dependientes_mayores =  @customer_credit_data[0]["dependientes_mayores"]
        @dependientes_menores = @customer_credit_data[0]["dependientes_menores"]
        @tipo_vivienda = @customer_credit_data[0]["tipo_vivienda"]
        @identificacion_oficial = @customer_credit_data[0]["pf_tipo_identificacion"]
        @ine = @customer_credit_data[0]["pf_numero_identificacion"]
        @telefono = @customer_credit_data[0]["pf_telefono"]
        @movil = @customer_credit_data[0]["pf_celular"]
        @email = @customer_credit_data[0]["pf_correo"]
        @gastos_renta = @customer_credit_data[0]["renta"]
        @antiguedad = @customer_credit_data[0]["antiguedad"]
        @otros_ingresos = @customer_credit_data[0]["otros_ingresos"]
        @creditos_personales = @customer_credit_data[0]["creditos_personales"]
        @creditos_lp = @customer_credit_data[0]["creditos_lp"]
        @customer_id = @customer_credit.customer_id
        # @destino = @customer_credit.destination
        @destino = @customer_credit_data[0]["destino"]
        @monto_total_solicitado = @customer_credit.total_requested
        @intereses_apertura = @monto_total_solicitado * 0.01
        @intereses_apertura = @intereses_apertura.round(2)
        @capital = @customer_credit.capital
        @intereses = @customer_credit.interests
        @iva = @customer_credit.iva
        @deuda_total = @customer_credit.total_debt
        @total_pagos = @customer_credit.total_payments
        @balance = @customer_credit.balance
        @status = @customer_credit.status
        @fecha_inicio = @customer_credit.start_date
        @dia_inicio = @fecha_inicio.strftime("%d")
        @mes_inicio = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Noviembre", "December" => "Diciembre" }.fetch(@fecha_inicio.strftime("%B"))
        @anio_inicio = @fecha_inicio.strftime("%Y")
        @fecha_fin = @customer_credit.end_date
        @dia_fin = @fecha_fin.strftime("%d")
        @mes_fin = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Noviembre", "December" => "Diciembre" }.fetch(@fecha_fin.strftime("%B"))
        @anio_fin = @fecha_fin.strftime("%Y")
        @tasa = @customer_credit.rate
        @person_id = @customer_credit_data[0]["person_id"]
        # ary = [@term,@plazo,@cuenta_bancaria,@cuenta_clabe,@banco,@calle,@numero_exterior,@numero_apartamento,@colonia,@codigo_postal,@estado,@municipio,@company,@company_contributor_id,@fecha_inicio_labores,@giro_empresa,@salario,@total_gastos,@frecuencia_de_pago,@ingreso_total,@otros_ingresos,@jefe_inmediato,@regimen_fiscal,@rfc,@curp,@NSS,@nombre,@apellido_paterno,@apellido_materno,@sexo,@nacionalidad,@lugar_nacimiento,@fecha_nacimiento,@age,@estado_civil,@regimen_marital,@dependientes_mayores,@dependientes_menores,@tipo_vivienda,@identificacion_oficial,@ine,@telefono,@movil,@email,@gastos_renta,@antiguedad,@otros_ingresos,@creditos_personales,@creditos_lp,@customer_id,@destino,@monto_total_solicitado,@capital,@intereses,@iva,@deuda_total,@total_pagos,@balance,@pagos_fijos,@status,@fecha_inicio,@dia_inicio,@mes_inicio,@anio_inicio,@fecha_fin,@dia_fin,@mes_fin,@anio_fin]
        # unless [@term,@plazo,@cuenta_bancaria,@cuenta_clabe,@banco,@calle,@numero_exterior,@numero_apartamento,@colonia,@codigo_postal,@estado,@municipio,@company,@company_contributor_id,@fecha_inicio_labores,@giro_empresa,@salario,@total_gastos,@frecuencia_de_pago,@ingreso_total,@otros_ingresos,@jefe_inmediato,@regimen_fiscal,@rfc,@curp,@NSS,@nombre,@apellido_paterno,@apellido_materno,@sexo,@nacionalidad,@lugar_nacimiento,@fecha_nacimiento,@age,@estado_civil,@regimen_marital,@dependientes_mayores,@dependientes_menores,@tipo_vivienda,@identificacion_oficial,@ine,@telefono,@movil,@email,@gastos_renta,@antiguedad,@otros_ingresos,@creditos_personales,@creditos_lp,@customer_id,@destino,@monto_total_solicitado,@capital,@intereses,@iva,@deuda_total,@total_pagos,@balance,@pagos_fijos,@status,@fecha_inicio,@dia_inicio,@mes_inicio,@anio_inicio,@fecha_fin,@dia_fin,@mes_fin,@anio_fin].include?(nil)
        # unless ary.include?(nil)
        # CUSTOMER COMPANY'S ADDRESS 
        @customer_company_address_data = Customer.get_customer_company_address(@customer_credit.id)
        unless @customer_company_address_data.blank?
          @company_colonia = @customer_company_address_data[0]["colonia"]
          @company_calle = @customer_company_address_data[0]["calle"]
          @company_numero_exterior = @customer_company_address_data[0]["numero_exrerior"]
          @company_codigo_postal = @customer_company_address_data[0]["codigo_postal"]
          @company_municipio_name = @customer_company_address_data[0]["municipio"]
          @company_state_name = @customer_company_address_data[0]["estado"]
        else
          @error_desc.push("No se encontró la informacion de la empresa del cliente")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        end
        # else
        # @error_desc.push("No se encontró un dato del cliente", ary.select {|k,v| k.blank?})
        # error_array!(@error_desc, :not_found)
        # raise ActiveRecord::Rollback
        # end
      else
        @error_desc.push("No se encontró la informacion del cliente (customer_credit_data)")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    else
      @error_desc.push("No se ha capturaro el analisis de credito")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
    @referencias_personales = CustomerPersonalReference.where(customer_id: @customer_credit.customer_id)
    unless @referencias_personales.blank?
      @amortizacion = PaymentCredit.get_credit_payments(@customer_credit.id)
      unless @amortizacion.blank?
        @fecha_primer_pago = @amortizacion[0]['payment_date']

        @file = CombinePDF.new
        @documents_array = ["solicitud","kyc","carta_deposito","domiciliacion","privacidad","prestamo","caratula_terminos","terminos2","pagare","amortizacion"]
        
        @documents_array.each do |document_name|
          render_pdf_to_s3(document_name)
        end

        @file.save "final_#{@folio}.pdf"
        file = URI.open(Rails.root.join("final_#{@folio}.pdf")).read
        @final_filename = "customer_credit_final_report_#{@folio}.pdf"
        path_final = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@final_filename}"
        s3_save(file,path_final)
        # file.close
        
        @url_final = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@final_filename}"
        #     LEFT JOIN people peo ON (peo.id = con.person_id)
        @person = Person.find_by_id(@person_id)
        @person.update(extra1: @url_final)
        # BORRA ARCHIVOS DE S3 CUANDO YA NO SE NECESITAN
        borra_documentos(@documents_array,@folio)
      else
        @error_desc.push("No se encontraron amortizaciones del cliente (get_credit_payments)")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    else
      @error_desc.push("No se encontraron refrencias personales del cliente")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
  end

  def render_pdf_to_s3(nombre_del_documento)

    @filename = "customer_credit_#{nombre_del_documento}_report_#{@folio}.pdf"
    pdf = render_to_string pdf: @filename, template: "#{nombre_del_documento}.pdf.erb", encoding: "UTF-8"
    @path = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@filename}"
    s3_save(pdf,@path)
    @url = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@filename}"
    URI.open("#{nombre_del_documento}.pdf", "wb") do |cd_file|
      cd_file.write open(@url).read
    end
    @file << CombinePDF.load(Rails.root.join("#{nombre_del_documento}.pdf"), allow_optional_content: true)

  end

  def documents_mode
    response = GeneralParameter.get_general_parameter_value('DOCUMENT_MODE')
    unless response.blank?
      unless response == 'NO' 
        return true
      else
        return false
      end
    else
      @error_desc.push("No se encontró el parámetro general DOCUMENT_MODE")
      error_array!(@error_desc, :not_found)
      
    end
  end

  def nomina_env 
    if ENV['RAILS_ENV'] == 'development'
      trae_local_env
    elsif ENV['RAILS_ENV'] == 'test'
      trae_local_env
    else 
      return trae_nomina_env
    end
  end

  def trae_local_env
    unless ENV['LOCAL_NOMINA_ENV'].blank?
      return ENV['LOCAL_NOMINA_ENV']
    else
      @error_desc.push("No se encontró la variable de entorno LOCAL_NOMINA_ENV")
      error_array!(@error_desc, :not_found)
      
     end
  end

  def trae_nomina_env
    unless ENV['NOMINA_ENV'].blank?
        return ENV['NOMINA_ENV']
      else
        @error_desc.push("No se encontró la variable de entorno NOMINA_ENV")
        error_array!(@error_desc, :not_found)
        
      end
  end

  def s3_save(file, s3_path)
    obj = s3.bucket(bucket_name).object(s3_path)
    obj.put(
      body: file,
      acl: "public-read" # optional: makes the file readable by anyone
      )
  end

  def s3    
      unless ENV['LOCAL_ACCESS_KEY_ID'].blank? || ENV['LOCAL_AWS_REGION'].blank?  || ENV['LOCAL_SECRET_ACCESS_KEY'].blank? || ENV['LOCAL_BUCKET_NAME'].blank?
        return Aws::S3::Resource.new(
          access_key_id:   ENV['LOCAL_ACCESS_KEY_ID'] ,
          region: ENV['LOCAL_AWS_REGION'],
          secret_access_key:  ENV['LOCAL_SECRET_ACCESS_KEY']
        )
      else
        @error_desc.push("No se encontraron las variables de entorno para AWS")
        error_array!(@error_desc, :not_found)
        
      end
  end

  def bucket_name
    unless ENV['LOCAL_BUCKET_NAME'].blank?
      return ENV['LOCAL_BUCKET_NAME']
    else
      @error_desc.push("No se encontró la variable de entorno LOCAL_BUCKET_NAME")
      error_array!(@error_desc, :not_found)
      
    end
  end

  def borra_de_local(document_name)
    File.delete(Rails.root.join("#{document_name}.pdf"))if File.exist?(Rails.root.join("#{document_name}.pdf"))
  end

  def borra_de_s3(document_name,folio)
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("nomina_customer_documents/#{nomina_env}/#{folio}/customer_credit_#{document_name}_report_#{folio}.pdf")
    obj.delete
  end

  def borra_documentos(documents_array,folio)

    documents_array.each do |document_name|
      # BORRA ARCHIVOS GUARDADOS LOCALMENTE CUANDO YA NO SE REQUIEREN
      borra_de_local(document_name)
      #BORRA ARCHIVOS GUARDADOS EN BUCKET S3
      borra_de_s3(document_name,folio)
    end
    borra_de_local("final_#{folio}")
  end

  def get_buro (customer_credit_id)
    @error_desc = []
  @customer_credit = CustomerCredit.find_by_id(customer_credit_id)
    # DEBE SER UNLESS
    unless @customer_credit.blank?
      @customer = Customer.find_by_id(@customer_credit.customer_id)
      unless @customer.blank?
      @contributor = Contributor.find_by_id(@customer.contributor_id)
      unless @contributor.blank?
        @person = Person.find_by_id(@contributor.person_id)
        unless @person.blank?
          @customer_data = Customer.get_customer_data(@customer.id)
          unless CreditBureau.exists?(customer_id: @customer_credit.customer_id)
            #REALIZA LA CONSULTA DE BURÓ
            # @info = SatW.get_tax_status @person.try(:rfc)
            # puts "@info"
            # puts @info.inspect

            @buro = create_buro 
            unless @buro == false
              @bureau_report = BuroCredito.get_buro_report @buro.first['id']
              @bureau_info = BuroCredito.get_buro_info @buro.first['id']
              @credit_bureau = CreditBureau.new(customer_id: @customer.id, bureau_report: @bureau_report, bureau_id: @buro.first['id'], bureau_info: @bureau_info)
              if @credit_bureau.save

                return @credit_bureau
                # if @bureau_report['results'].present?
                  # if @bureau_report['results'][0]['response'].present?
                    # @report_result = @bureau_report['results'][0]
                  # else
                    # @report_result = @bureau_report['results'][1]
                  # end
                # else
                # end
                # puts @report_result['results'][0]['response']['return']['Personas']['Persona'][0]['Nombre']['PrimerNombre'] + ' ' + @report_result['results'][0]['response']['return']['Personas']['Persona'][0]['Nombre']['ApellidoPaterno']
              else
                @error_desc.push("Hubo un error al guardar el CreditBureau favor volver a intentar")
                error_array!(@error_desc, :not_found)
              end
            else
              @error_desc.push("Hubo un error crear registro de buro/No se pudo registrar al cliente BuroCredito.create_client")
              error_array!(@error_desc, :not_found)
            end
        else
          p "NO REALIZA LA CONSULTA PUES YA ESTA GUARDADA EN DB"
          @credit_bureau = CreditBureau.where(customer_id: @customer_credit.customer_id)
          unless @credit_bureau.blank?
          # RETURNS BURO REPORTS AS JSON
            return @credit_bureau
          else
            # NO SE ENCONTRÓ BURÓ
            render json: { message: "No se encontró reporte de buró en tabla credit_bureaus" }, status: 404
            end
        end
        else
          @error_desc.push("No se encontró person")
          error_array!(@error_desc, :not_found)
          # raise ActiveRecord::Rollback
        end
      else
        @error_desc.push("No se encontró contributor")
        error_array!(@error_desc, :not_found)
        # raise ActiveRecord::Rollback
      end
      else
        @error_desc.push("No se encontró customer")
        error_array!(@error_desc, :not_found)
        # raise ActiveRecord::Rollback
      end
    else
      # @error_desc.push("No se encontró cliente")
      # error_array!(@error_desc, :not_found)
      # NO SE ENCONTRÓ 
      render json: { message: "No se encontró registro", customer: "#{@customer_credit[0].inspect}", status: false
      }, status: 206
      # raise ActiveRecord::Rollback
    end
  end

  # RECIBE customer_credit Y DEVUELVE URL DEL PDF GENERADO
  def generate_customer_buro_report_pdf(customer_credit_id)
    @error_desc = []
    @customer_credit = CustomerCredit.find_by_id(customer_credit_id)
    unless @customer_credit.blank?
      @customer = Customer.find_by_id(@customer_credit.customer_id)
      unless @customer.blank?
        @credit_bureau = CreditBureau.where(customer_id: @customer_credit.customer_id)
        unless @credit_bureau.blank?
          @bureau_report = @credit_bureau[0].bureau_report
          @bureau_info = @credit_bureau[0].bureau_info
          @report_result = @bureau_report
          if @report_result['results'][0]['metadata']['clientType'] == 'PM' || @report_result['results'][0]['metadata']['clientType'] == 'PFAE'
            # puts "SI ES PERSONA MORAL"
            @esPM = true
            @buro_score = @report_result['results'][0]['query']['consulta']['encabezado']['scoreCode']
            # puts @buro_score
          else
            @esPM = false
            if @report_result.has_key?("msjError".to_sym)
              if @report_result['results'][0]['response']['respuesta']['msjError'] == 'No existe informacion crediticia para esta consulta'
                @buro_score = @report_result['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']
                @score = @buro_score['ScoreBC'][0]['ValorScore'].to_i              
              else
                @buro_score = @report_result['results'][0]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']
                @score = @buro_score['ScoreBC'][0]['ValorScore'].to_i
              
              end
            else
              @buro_score = @report_result['results'][1]['response']['return']['Personas']['Persona'][0]['ScoreBuroCredito']
              @score = @buro_score['ScoreBC'][0]['ValorScore'].to_i
            end
          end
            @filename = "Reporte Buró de Crédito #{@customer.id}.pdf"
            pdf = render_to_string pdf: @filename, template: "credit_bureau.pdf.erb", encoding: "UTF-8"
            @path = "nomina_customer_documents/#{nomina_env}/bureau/#{@filename}"
            s3_save(pdf,@path)
            @url = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/bureau/#{@filename}"
            # puts "@url"
            # puts @url

            @credit_bureau.update(extra1: @url)
            return @url
        else
          @error_desc.push("No tiene guardada consulta de buro")
          error_array!(@error_desc, :not_found)
          raise ActiveRecord::Rollback
        end
      else
        @error_desc.push("No se encuentra el customer")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end
    else
      @error_desc.push("No se encuentra el customer credit")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
  end

  def update_profile(id)
    @buro = BuroCredito.update_profile id
  end

  def create_buro
    rfc = @customer_data[0]["pf_rfc"]
    email = @customer_data[0]["pf_correo"]
    address = @customer_data[0]["calle"]
    city = @customer_data[0]["municipio"]
    state = get_state @customer_data[0]["estado"]
    zip_code = @customer_data[0]["codigo_postal"]
    interior_number = @customer_data[0]["numero_apartamento"]
    exterior_number = @customer_data[0]["numero_exterior"]
    municipality = @customer_data[0]["municipio"]

    if @customer_data[0]["tipo_contribuyente"] != 'PF'
      account_type = "PM"
    else
      first_name = @customer_data[0]["nombre"]
      first_last_name =  @customer_data[0]["apellido_paterno"]
      second_last_name = @customer_data[0]["apellido_materno"]
      account_type = "PF"
    end

    data = [accountType: account_type, email: email, firstName: first_name, middleName: "", rfc: rfc,
            firstLastName: first_last_name, secondLastName: second_last_name, address: address, city: city,
            state: state, zipCode: zip_code, exteriorNumber: exterior_number, interiorNumber: interior_number,
            neighborhood: "", municipality: municipality,
            nationality: "MX"]
    @buro = BuroCredito.create_client data

    p "@buro 2 --------------------------------------------------------------------------------"
    p @buro

    if @buro['result'].present?
      response = @buro['result']
    else
      response = false

    end

    return response
  end

  def get_state state
    if state == 'Aguascalientes' || state == 'aguascalientes'
      new_state = 'AGS'
    elsif state == 'Baja California Norte' || state == 'baja california norte'
      new_state = 'BCN'
    elsif state == 'Baja California Sur' || state == 'baja california sur'
      new_state = 'BCS'
    elsif state == 'Campeche' || state == 'campeche'
      new_state = 'CAM'
    elsif state == 'Ciudad de México' || state == 'ciudad de méxico' || state == 'ciudad de mexico' || state == 'Ciudad de Mexico'
      new_state = 'CDMX'
    elsif state == 'Chiapas' || state == 'chiapas'
      new_state = 'CHS'
    elsif state == 'Chihuahua' || state == 'chihuahua'
      new_state = 'CHI'
    elsif state == 'Coahuila' || state == 'coahuila'
      new_state = 'COA'
    elsif state == 'Colima' || state == 'colima'
      new_state = 'COL'
    elsif state == 'Durango' || state == 'durango'
      new_state = 'DGO'
    elsif state == 'Estado de Mexico' || state == 'estado de mexico' || state == 'Estado De Mexico'
      new_state = 'EM'
    elsif state == 'Guanajuato' || state == 'guanajuato'
      new_state = 'GTO'
    elsif state == 'Guerrero' || state == 'guerrero'
      new_state = 'GRO'
    elsif state == 'Hidalgo' || state == 'hidalgo'
      new_state = 'HGO'
    elsif state == 'Jalisco' || state == 'jalisco'
      new_state = 'JAL'
    elsif state == 'Michoacan' || state == 'michoacan'
      new_state = 'MICH'
    elsif state == 'Morelia' || state == 'morelia'
      new_state = 'MOR'
    elsif state == 'Nayarit' || state == 'nayarit'
      new_state = 'NAY'
    elsif state == 'Nuevo Leon' || state == 'nuevo leon'
      new_state = 'NL'
    elsif state == 'Oaxaca' || state == 'oaxaca'
      new_state = 'OAX'
    elsif state == 'Puebla' || state == 'puebla'
      new_state = 'PUE'
    elsif state == 'Quintana Roo' || state == 'quintana roo'
      new_state = 'QRO'
    elsif state == 'Queretaro' || state == 'queretaro'
      new_state = 'QR'
    elsif state == 'San Luis Potosi' || state == 'san luis potosi'
      new_state = 'SLP'
    elsif state == 'Sinaloa' || state == 'sinaloa'
      new_state = 'SIN'
    elsif state == 'Sonora' || state == 'sonora'
      new_state = 'SON'
    elsif state == 'Tabasco' || state == 'tabasco'
      new_state = 'TAB'
    elsif state == 'Tamaulipas' || state == 'tamaulipas'
      new_state = 'TAM'
    elsif state == 'Tlaxcala' || state == 'tlaxcala'
      new_state = 'TLAX'
    elsif state == 'Veracruz' || state == 'veracruz'
      new_state = 'VER'
    elsif state == 'Yucatan' || state == 'yucatan'
      new_state = 'YUC'
    elsif state == 'Zacatecas' || state == 'zacatecas'
      new_state = 'ZAC'
    end

    return new_state
  end

  def send_register_mail(nombre,correo,empresa)
      @query = 
      "SELECT u.email as email,u.name as name,r.name as tipo, u.id
      FROM users u, roles r
      WHERE u.role_id = r.id
      AND u.job IN ('ADMINISTRADOR')"
    response = execute_statement(@query)
    unless response.blank?
      @mailer_signatories = response.to_a
      @frontend_url = GeneralParameter.get_general_parameter_value('FRONTEND_URL')
      @mailer_signatories.each do |mailer_signatory|
        mail_to = mailer_mode_to(mailer_signatory['email'])
        #email, name, subject, title, content
        SendMailMailer.analyst2(mail_to,
          mailer_signatory['name'],
          "Factor GFC Global - Credi Global - #{nombre} está interesado en un credito",
          "Dar de alta como Cliente para iniciar su registro",
          [@frontend_url,nombre,
          correo,
          empresa]
        ).deliver_now
      end
      render json: { message: 'Ok', status:true }, status: 200
    else
      render json: { message: "No se encontraron analistas", status: false }, status: 206
    end
  end

end