# frozen_string_literal: true
require 'aws-sdk-s3'  # v2: require 'aws-sdk'
require 'json'
require 'combine_pdf'
require 'open-uri'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  # respond_to :json

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
    generate_customer_credit_request_report_pdf
    if response.blank?
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

  #CREA REPORTE CON TODOS LAS VARIABLES DE SOLICITUD DE CREDITO Y GUARDARLO EN S3
  #TO DO: DESPUES DEBE ADJUNTARSE ESTE PDF CON EL SIGUIENTE PARA HACER UNO SOLO CON EL CONBINE PD
  def generate_customer_credit_request_report_pdf
    @mail_factor = 'sistemasfgfc@gmail.com'
    @folio = @customer_credit.id
    @lugar = 'Chihuahua, Chihuahua'
    get_customer_credit_data
    @term = @customer_credit_data[0]["numero_pagos"]
    @plazo = @customer_credit_data[0]["plazo"]
    @date = Time.now.strftime("%d/%m/%Y")
    @dia = Time.now.strftime("%d")
    @mes = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Nobiembre", "December" => "Diciembre" }.fetch(Date.today.strftime("%B"))
    @anio = Time.now.strftime("%Y")
    @customer_id = @customer_credit.customer_id
    @destino = @customer_credit.destination
    @monto_total_solicitado = @customer_credit.total_requested
    @capital = @customer_credit.capital
    @intereses = @customer_credit.interests
    @iva = @customer_credit.iva
    @deuda_total = @customer_credit.total_debt
    @total_pagos = @customer_credit.total_payments
    @balance = @customer_credit.balance
    @pagos_fijos = @customer_credit.fixed_payment
    @status = @customer_credit.status
    @fecha_inicio = @customer_credit.start_date
    @dia_inicio = @fecha_inicio.strftime("%d")
    @mes_inicio = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Nobiembre", "December" => "Diciembre" }.fetch(@fecha_inicio.strftime("%B"))
    @anio_inicio = @fecha_inicio.strftime("%Y")
    @fecha_fin = @customer_credit.end_date
    @dia_fin = @fecha_fin.strftime("%d")
    @mes_fin = { "January" => "Enero", "February" => "Febrero","March" => "Marzo","April" => "Abril","May" => "Mayo","June" => "Junio","July" => "Julio","August" => "Agosto","September" => "Septiembre","October" => "Octubre", "November" => "Nobiembre", "December" => "Diciembre" }.fetch(@fecha_fin.strftime("%B"))
    @anio_fin = @fecha_fin.strftime("%Y")
    @cuenta_bancaria = @customer_credit_data[0]["cuenta_bancaria"]
    @cuenta_clabe = @customer_credit_data[0]["cuenta_clabe"]
    @banco = @customer_credit_data[0]["banco"]
    @calle = @customer_credit_data[0]["calle"]
    @numero_exterior = @customer_credit_data[0]["numero_exterior"]
    @numero_apartamento = @customer_credit_data[0]["numero_apartamento"]
    @colonia = @customer_credit_data[0]["colonia"]
    @codigo_postal = @customer_credit_data[0]["codigo_postal"]
    # @suburb_type = @customer_credit_data[0][""]
    @estado = @customer_credit_data[0]["estado"]
    @country = @customer_credit_data[0]["pais"]
    @municipio = @customer_credit_data[0]["municipio"]
    @company = @customer_credit_data[0]["nombre_empresa"]
    @company_contributor_id = @customer_credit_data[0]["company_contributor_id"]
    # CUSTOMER COMPANY'S ADDRESS
    get_customer_company_address
    @company_colonia = @customer_company_address_data[0]["colonia"]
    @company_calle = @customer_company_address_data[0]["calle"]
    @company_numero_exterior = @customer_company_address_data[0]["numero_exrerior"]
    @company_codigo_postal = @customer_company_address_data[0]["codigo_postal"]
    @company_municipio_name = @customer_company_address_data[0]["municipio"]
    @company_state_name = @customer_company_address_data[0]["estado"]

    @fecha_inicio_labores = @customer_credit_data[0]["fecha_inicio_labores"]
    @giro_empresa = @customer_credit_data[0]["giro_empresa"]
    @salario = @customer_credit_data[0]["salario"]
    @total_gastos = @customer_credit_data[0]["total_gastos"]
    @frecuencia_de_pago = @customer_credit_data[0]["frecuencia_de_pago"]
    @ingreso_total = @customer_credit_data[0]["ingreso_total"]
    @otros_ingresos = @customer_credit_data[0]["ingreso_total"]
    @jefe_inmediato = @customer_credit_data[0]["jefe_inmediato"]
    @regimen_fiscal = @customer_credit_data[0]["pm_regimen_fiscal"]
    @rfc = @customer_credit_data[0]["pf_rfc"]
    @curp =@customer_credit_data[0]["pf_curp"]
    @NSS = @customer_credit_data[0]["pf_numero_seguro_social"]
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
    @referencias_personales = CustomerPersonalReference.where(customer_id: @customer_credit.customer_id)
    @filename = "customer_credit_request_report_#{@folio}.pdf"

    # GUARDA EL PDF EN MEMORIA
    pdf = render_to_string pdf: @filename, template: "solicitud.pdf.erb", encoding: "UTF-8"
    @path = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@filename}"
    # puts "path"
    # puts path
    # puts "path"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf,@path)
    # puts "TERMINA DE GUARDAR EN S3"
    
    @url = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@filename}"
    # puts 
    # puts @url
    File.open('solicitud.pdf', "wb") do |cd_file|
      cd_file.write open(@url).read
    end

    @file = CombinePDF.new
    @file << CombinePDF.load(Rails.root.join('solicitud.pdf'), allow_optional_content: true)
    # DESCOMENTAR
    @kyc_filename = "customer_credit_kyc_report_#{@folio}.pdf"
    pdf_nyc = render_to_string pdf: @kyc_filename, template: "kyc.pdf.erb", encoding: "UTF-8"
    @path_kyc = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@kyc_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_nyc,@path_kyc)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_kyc = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@kyc_filename}"
    # puts 
    # puts @url_kyc
    File.open('kyc.pdf', "wb") do |cd_file|
      cd_file.write open(@url_kyc).read
    end
    @file << CombinePDF.load(Rails.root.join('kyc.pdf'), allow_optional_content: true)

    @carta_deposito_filename = "customer_credit_carta_deposito_report_#{@folio}.pdf"
    pdf_carta_deposito = render_to_string pdf: @carta_deposito_filename, template: "carta_conformidad_deposito.pdf.erb", encoding: "UTF-8"
    @path_carta_deposito = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@carta_deposito_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_carta_deposito,@path_carta_deposito)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_carta_deposito = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@carta_deposito_filename}"
    # puts 
    # puts @url_carta_deposito
    File.open('carta_deposito.pdf', "wb") do |cd_file|
      cd_file.write open(@url_carta_deposito).read
    end
    @file << CombinePDF.load(Rails.root.join('carta_deposito.pdf'), allow_optional_content: true)

    
    @domiciliacion_filename = "customer_credit_domiciliacion_report_#{@folio}.pdf"
    pdf_domiciliacion = render_to_string pdf: @domiciliacion_filename, template: "domiciliacion.pdf.erb", encoding: "UTF-8"
    @path_domiciliacion = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @domiciliacion_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_domiciliacion,@path_domiciliacion)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_domiciliacion = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@domiciliacion_filename}"
    # puts 
    # puts @url_domiciliacion
    File.open('domiciliacion.pdf', "wb") do |cd_file|
      cd_file.write open(@url_domiciliacion).read
    end

    @privacidad_filename = "customer_credit_privacidad_report_#{@folio}.pdf"
    pdf_privacidad = render_to_string pdf: @privacidad_filename, template: "privacidad.pdf.erb", encoding: "UTF-8"
    @path_privacidad = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @privacidad_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_privacidad,@path_privacidad)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_privacidad = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@privacidad_filename}"
    # puts 
    # puts @url_privacidad
    File.open('privacidad.pdf', "wb") do |cd_file|
      cd_file.write open(@url_privacidad).read
    end
    @file << CombinePDF.load(Rails.root.join('privacidad.pdf'), allow_optional_content: true)
    
    @caratula_terminos_filename = "customer_credit_caratula_terminos_report_#{@folio}.pdf"
    pdf_caratula_terminos = render_to_string pdf: @caratula_terminos_filename, template: "caratula_terminos.pdf.erb", encoding: "UTF-8"
    @path_caratula_terminos = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @caratula_terminos_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_caratula_terminos,@path_caratula_terminos)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_caratula_terminos = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@caratula_terminos_filename}"
    # puts 
    # puts @url_caratula_terminos
    File.open('caratula_terminos.pdf', "wb") do |cd_file|
      cd_file.write open(@url_caratula_terminos).read
    end
    @file << CombinePDF.load(Rails.root.join('caratula_terminos.pdf'), allow_optional_content: true)

    @prestamo_filename = "customer_credit_prestamo_report_#{@folio}.pdf"
    pdf_prestamo = render_to_string pdf: @prestamo_filename, template: "prestamo.pdf.erb", encoding: "UTF-8"
    @path_prestamo = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @prestamo_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_prestamo,@path_prestamo)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_prestamo = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@prestamo_filename}"
    # puts 
    # puts @url_prestamo
    File.open('prestamo.pdf', "wb") do |cd_file|
      cd_file.write open(@url_prestamo).read
    end
    @file << CombinePDF.load(Rails.root.join('prestamo.pdf'), allow_optional_content: true)

    @terminos2_filename = "customer_credit_terminos2_report_#{@folio}.pdf"
    pdf_terminos2 = render_to_string pdf: @terminos2_filename, template: "terminos2.pdf.erb", encoding: "UTF-8"
    @path_terminos2 = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @terminos2_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_terminos2,@path_terminos2)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_terminos2 = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@terminos2_filename}"
    # puts 
    # puts @url_terminos2
    File.open('terminos2.pdf', "wb") do |cd_file|
    cd_file.write open(@url_terminos2).read
    end
    @file << CombinePDF.load(Rails.root.join('terminos2.pdf'), allow_optional_content: true)

    @pagare_filename = "customer_credit_pagare_report_#{@folio}.pdf"
    pdf_pagare = render_to_string pdf: @pagare_filename, template: "pagare.pdf.erb", encoding: "UTF-8"
    @path_pagare = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{ @pagare_filename }"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(pdf_pagare,@path_pagare)
    # puts "TERMINA DE GUARDAR EN S3"
    @url_pagare = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@pagare_filename}"
    # puts 
    # puts @url_pagare
    File.open('pagare.pdf', "wb") do |cd_file|
      cd_file.write open(@url_pagare).read
    end
    @file << CombinePDF.load(Rails.root.join('pagare.pdf'), allow_optional_content: true)

    
    @file.save "final_#{@folio}.pdf"
    file = File.open(Rails.root.join("final_#{@folio}.pdf"))
    @final_filename = "customer_credit_final_report_#{@folio}.pdf"
    path_final = "nomina_customer_documents/#{nomina_env}/#{@folio}/#{@final_filename}"
    # puts "INTENTA GUARDAR EN S3"
    s3_save(file,path_final)
    # puts "TERMINA DE GUARDAR EN S3"
    file.close
    
    @url_final = "https://#{bucket_name}.s3.amazonaws.com/nomina_customer_documents/#{nomina_env}/#{@folio}/#{@final_filename}"
    puts 
    puts @url_final
    # byebug

    # @request.update(attached: @url)

    # BORRA ARCHIVOS GUARDADOS LOCALMENTE CUANDO YA NO SE REQUIEREN
    File.delete(Rails.root.join("solicitud.pdf"))if File.exist?(Rails.root.join("solicitud.pdf"))
    File.delete(Rails.root.join("kyc.pdf"))if File.exist?(Rails.root.join("kyc.pdf"))
    File.delete(Rails.root.join("carta_deposito.pdf"))if File.exist?(Rails.root.join("carta_deposito.pdf"))
    File.delete(Rails.root.join("domiciliacion.pdf"))if File.exist?(Rails.root.join("domiciliacion.pdf"))
    File.delete(Rails.root.join("privacidad.pdf"))if File.exist?(Rails.root.join("privacidad.pdf"))
    File.delete(Rails.root.join("terminos2.pdf"))if File.exist?(Rails.root.join("terminos2.pdf"))
    File.delete(Rails.root.join("pagare.pdf"))if File.exist?(Rails.root.join("pagare.pdf"))
    File.delete(Rails.root.join("prestamo.pdf"))if File.exist?(Rails.root.join("prestamo.pdf"))
    File.delete(Rails.root.join("caratula_terminos.pdf"))if File.exist?(Rails.root.join("caratula_terminos.pdf"))
    File.delete(Rails.root.join("final_#{@folio}.pdf"))if File.exist?(Rails.root.join("final_#{@folio}.pdf"))

    # BORRA ARCHIVOS DE S3 CUANDO YA NO SE NECESITAN
    borra
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
      raise ActiveRecord::Rollback
     end
  end

  def trae_nomina_env
    unless ENV['NOMINA_ENV'].blank?
        return ENV['NOMINA_ENV']
      else
        @error_desc.push("No se encontró la variable de entorno NOMINA_ENV")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
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
        raise ActiveRecord::Rollback
      end
  end

  def bucket_name
    unless ENV['LOCAL_BUCKET_NAME'].blank?
      return ENV['LOCAL_BUCKET_NAME']
    else
      @error_desc.push("No se encontró la variable de entorno LOCAL_BUCKET_NAME")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
  end

  def get_customer_credit_data

    @query = "SELECT ter.value numero_pagos, ter.description plazo , pap.value periodo_pago, 
    cus.credit_lp creditos_lp,cus.credit_cp creditos_personales,cus.seniority antiguedad,cus.house_rent renta,cus.immediate_superior jefe_inmediato,cus.other_income otros_ingresos,cus.total_income ingreso_total,cus.salary_period frecuencia_de_pago,cus.net_expenses total_gastos,cus.salary salario,cus.id id_cliente, cus.name nombre_cliente, cus.customer_type tipo_cliente, cus.status status_cliente, cus.user_id id_usuario, cus.file_type_id id_tipo_expediente, con.id id_contribuyente, 
    con.contributor_type tipo_contribuyente, con.bank banco, con.account_number cuenta_bancaria, con.clabe cuenta_clabe, con.person_id id_persona_fisica, con.legal_entity_id id_persona_moral, peo.fiscal_regime pf_regimen_fiscal, 
    peo.rfc pf_rfc, peo.curp pf_curp, peo.imss pf_numero_seguro_social, peo.first_name nombre, peo.last_name apellido_paterno, peo.second_last_name apellido_materno, peo.gender pf_genero, 
    peo.nationality pf_nacionalidad, peo.birthplace pf_lugar_nacimiento, peo.birthdate pf_fecha_nacimiento, peo.martial_status pf_estado_civil,peo.martial_regime pf_regimen_marital,peo.senior_dependents dependientes_mayores,peo.minior_dependents dependientes_menores,peo.housing_type tipo_vivienda, peo.id_type pf_tipo_identificacion, peo.identification pf_numero_identificacion, 
    peo.phone pf_telefono, peo.mobile pf_celular, peo.email pf_correo, peo.fiel pf_fiel, lee.fiscal_regime pm_regimen_fiscal, lee.rfc pm_rfc, lee.rug pm_rug, lee.business_name pm_nombre, lee.phone pm_telefono, lee.mobile pm_celular, 
    lee.email pm_correo, lee.business_email pm_correo_negocio, lee.main_activity pm_actividad_pricipal, lee.fiel pm_fiel, coa.street calle, coa.suburb colonia, coa.external_number numero_exterior,coa.apartment_number numero_apartamento, coa.postal_code codigo_postal,
    sta.name estado, mun.name municipio, cou.name pais,com.business_name nombre_empresa , com.start_date fecha_inicio_labores, com.sector giro_empresa,com.contributor_id company_contributor_id, cpr
    FROM customer_credits cuc
    JOIN customers cus ON (cus.id = cuc.customer_id)
    JOIN companies com ON (cus.company_id = com.id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    JOIN terms ter ON (ter.id = cuc.term_id)
    JOIN customer_personal_references cpr ON (cpr.customer_id = cus.id)
    JOIN payment_periods pap ON (pap.id = cuc.payment_period_id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    LEFT JOIN legal_entities lee ON (lee.id = con.legal_entity_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
            WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', @customer_credit.id.to_s
    response = execute_statement(@query)
    @customer_credit_data = response

  end

  def get_customer_company_address
    @query = "SELECT  coa.suburb colonia,coa.street calle, coa.external_number numero_exterior,
    coa.postal_code codigo_postal, mun.name municipio, sta.name estado
    FROM customer_credits cuc
      JOIN customers cus ON (cus.id = cuc.customer_id)
      JOIN contributors con ON (cus.contributor_id = con.id)
      JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
      JOIN states sta ON (sta.id = coa.state_id)
      JOIN municipalities mun ON (mun.id = coa.municipality_id)
              WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', @customer_credit.id.to_s
    response = execute_statement(@query)
    @customer_company_address_data = response

  end

  def borra
    #delete files from bucket
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_kyc}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_carta_deposito}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_domiciliacion}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_privacidad}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_caratula_terminos}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_prestamo}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_terminos2}")
    obj.delete
    bucket = s3.bucket(bucket_name)
    obj = bucket.object("#{@path_pagare}")
    obj.delete
  end

end

