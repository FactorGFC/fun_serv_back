# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include UserAuthentication
  # before_action :authenticate
  before_action :set_jbuilder_defaults
  before_action :set_mailer_defaults

  protected

  def authenticate
    token_str = params[:token]
    token = Token.find_by(token: token_str)

    if token.nil? || !token.is_valid? || !@my_app.is_your_token?(token)
      # render json: {error: "Tu Token es inválido" }, status: :unauthorized
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
  
    if results.present?
      return results
    else
      return nil
    end
  end

  def val_cfdi(emisor, receptor, total, uuid)

    sat_cfdi_val_mode = GeneralParameter.get_general_parameter_value('SAT_CFDI_VAL_MODE')
    if sat_cfdi_val_mode == 'SI'
      xml = GeneralParameter.get_general_parameter_value('SAT_CFDI_VAL_XML')
      sat_cfdi_val_url = GeneralParameter.get_general_parameter_value('SAT_CFDI_VAL_URL')
      sat_cfdi_val_action = GeneralParameter.get_general_parameter_value('SAT_CFDI_VAL_ACTION')

      if sat_cfdi_val_mode.blank? || xml.blank? || sat_cfdi_val_url.blank? || sat_cfdi_val_action.blank?
        @error_desc.push("No se han configurado los parámetros generales para validacion de facturas en el SAT")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      end

      xml = xml.gsub ':emisor', emisor
      xml = xml.gsub ':receptor', receptor
      xml = xml.gsub ':total', total.to_s
      xml = xml.gsub ':uuid', uuid
      
      @client = Savon.client(wsdl: sat_cfdi_val_url)#"https://consultaqr.facturaelectronica.sat.gob.mx/ConsultaCFDIService.svc?wsdl")
      response = @client.call(:consulta, soap_header: { 'Content-type': 'text/xml;charset="utf-8"', Accept: 'text/xml', SOAPAction: sat_cfdi_val_action},#'http://tempuri.org/IConsultaCFDIService/Consulta'}, 
                                        xml: xml)
      if response.blank?
        'SIN RESPUESTA SAT'
      else
        @data = response.to_hash[:consulta_response][:consulta_result]
        @data[:estado]
      end
    else
      'Vigente' 
    end
  end

  def create_customer_credit(total_requested, status, start_date, customer_id, term_id, payment_period_id, rate, project_request_id, project_id)
    @term_id = term_id
    @payment_period_id = payment_period_id
    @rate = rate
    unless status == 'SI'
      unless project_request_id.blank?              
        @customer_credit = CustomerCredit.new(total_requested: total_requested, status: status, start_date: start_date, customer_id: customer_id, project_request_id: project_request_id)        
      else        
        @customer_credit = CustomerCredit.new(total_requested: total_requested, status: status, start_date: start_date, customer_id: customer_id, project_id: project_id)        
      end
    else
      @customer_credit = CustomerCredit.new(total_requested: total_requested, status: status, start_date: start_date, customer_id: customer_id)
    end
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

  def calculate_final_rate_pesos
    @error_desc = []
    @parameter_key_tiie = GeneralParameter.get_general_parameter_value('CLAVE_TIIE')
    if @parameter_key_tiie.nil?
      @error_desc.push('No se encontró el parámetro general CLAVE_TIIE')
      @resp = :not_found
    else
      @tiie_rate = ExtRate.where(key: @parameter_key_tiie, start_date: @tiie_date)
      if @tiie_rate.empty?
        @banxico_url = GeneralParameter.get_general_parameter_value('BANXICO_URL')
        @banxico_token = GeneralParameter.get_general_parameter_value('BANXICO_TOKEN')
        @banxico_serie = GeneralParameter.get_general_parameter_value('BANXICO_SERIE_TIIE28D')
        if @banxico_url.blank? || @banxico_token.blank? || @banxico_serie.blank?
          @error_desc.push('No se encontró el parámetro general CLAVE_TIIE')
          @resp = :not_found
        else
          @banxico_url = @banxico_url.gsub '<:serie>', @banxico_serie
          @banxico_url = @banxico_url.gsub '<:fechaini>', @tiie_date.to_s
          @banxico_url = @banxico_url.gsub '<:fechafin>', @tiie_date.to_s
          @banxico_url = @banxico_url.gsub '<:token>', @banxico_token
          # logger.info "@banxico URL: #{@banxico_url}"
          #puts "banxico_url: #{@banxico_url}"
          response = RestClient.get(@banxico_url)
          json = JSON.parse(response.to_str)
          if json.nil?
            @error_desc.push("No se pudo obtener la tarifa TIEE 28 días de Banco de México con fecha de inicio: #{@tiie_date}")
            error_array!(@error_desc, :not_found)
            raise ActiveRecord::Rollback
          else
            if json['bmx']['series'][0]['datos'].blank?
              @error_desc.push("La tarifa TIEE 28 días de Banco de México con fecha de inicio: #{@tiie_date} aún no está disponible")
              error_array!(@error_desc, :not_found)
              raise ActiveRecord::Rollback
            else
              @final_rate = json['bmx']['series'][0]['datos'][0]['dato']
              @ext_rate = ExtRate.create(key: 'tiie_28dias', description: 'Tasa de interés interbancaria a 28 días insertada desde baxico', start_date: @tiie_date,
                                  end_date: @tiie_date, value: @final_rate, rate_type: 'porcentaje')
              if @ext_rate.nil?
                @error_desc.push("No se pudo insertar la tasa tiie_28dias para la fecha: #{@tiie_date}")
                error_array!(@error_desc, :not_found)
                raise ActiveRecord::Rollback
              end
            end
          end
        end
      else
        @final_rate = @tiie_rate[0].value
      end
    end
  end

  private

  def calculate_customer_payments
    @error_desc = []
    customer_credit_id = @customer_credit.id
    term = @term.value
    payment_period = @payment_period.value
    total_requested = @customer_credit.total_requested
    rate = (@rate.to_f  / payment_period.to_f) / 100
    rate_with_iva = rate.to_f * 1.16
    start_date = @customer_credit.start_date    
    payment_amount = (rate_with_iva.to_f * total_requested.to_f) / (1 - ((1 + (rate_with_iva.to_f)) ** (-term.to_f)))
    @fixed_payment = payment_amount
    remaining_debt = 0
    1.upto(term) do |i|
      if i == 1
        interests = total_requested.to_f * rate.to_f
        iva = interests.to_f * 0.16
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = total_requested.to_f
        remaining_debt = total_requested.to_f - capital.to_f        
        payment = capital.to_f + interests.to_f + iva.to_f
      else
        interests = remaining_debt.to_f * rate.to_f
        iva = interests.to_f * 0.16
        capital = payment_amount.to_f - interests.to_f - iva.to_f
        current_debt = remaining_debt.to_f
        remaining_debt = remaining_debt.to_f - capital.to_f
        payment = capital.to_f + interests.to_f + iva.to_f
      end
      @capital = @capital + capital
      @interests = @interests + interests
      @iva = @iva + iva            
      case payment_period.to_s
      when '365'
        payment_date = start_date + term.days
      when '12'
        payment_date = start_date + i.months
      when '1'
        payment_date = start_date + i.years
      when '6'
        payment_date = start_date + (i*2).months
      when '4'
        payment_date = start_date + (i*3).months
      else
        @error_desc.push("No existe el periodo de pago: #{payment_period}, El tipo de periodo de debe de ser: Dias(365), Meses(12), Años(1), Bimestres(6), Trimestres(4)")
        error_array!(@error_desc, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
      sim_customer_payments = SimCustomerPayment.create(customer_credit_id: customer_credit_id, pay_number: i, current_debt: current_debt.round(2), remaining_debt:  remaining_debt.round(2), payment: payment.round(2),
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