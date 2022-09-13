# frozen_string_literal: true
require 'json'

class SessionsController < ApplicationController

  def create
    auth = { email: params[:email], password: params[:password] }
    user = User.from_omniauth(auth)

    if !user.nil?
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to '/my_apps' }
      end
    else
      redirect_to '/', notice: 'Combinación de correo/contraseña inválida'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end

#CUANDO EL CLIENTE/EMPLEADO ACEPTA EL CREDITO
  def get_callback
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless @customer_credit.blank?
      if @customer_credit[0].extra2 > Time.now
          # if @customer_credit[0].status == 'PR'
            @customer_credit.update(status: 'AC')
            @customer_credit.update(extra3: "#{params[:call_back_token]}-AC")
            #MANDA UN MAILER A MESA DE CONTROL PARA QUE ANALICE Y PASE EL CREDITO A FINANZAS/TESORERIA
            send_control_desk_mailer(@customer_credit[0].id)
            render json: { message: 'Ok, Credito actualizado con exito (ACEPTADO)' }, status: 200
          # else
            # render json: { message: "El credito ya ha sido actualizado por el cliente #{@customer_credit.status}", status: false }, status: 206
          # end
      else
        render json: { message: "Token expiró el #{@customer_credit[0].extra2}", status: false }, status: 206
      end
    else 
      render json: { message: "No encuentra el customer credit", place: "get_callback",status: false }, status: 206
    end
  end

#MAILER DE ESTADO DE CUENTA
  def send_account_status_mailer
    @id = params[:id]
    response = PaymentCredit.get_credit_payments(@id)
    unless response.blank?
      SendMailMailer.send_email_account_status(
            "dgonzalez@factorgfc.com", #response[0]['email'],
            response[0]['name'],
            "Estado de cuenta",
            "Estado de cuenta",
            response
          ).deliver_now
      render json: { message: response }, status: 200
    else
      render json: { message: 'No se encontraron registros' }, status: 400
    end
  end


#CUANDO EL CLIENTE/EMPLEADO RECHAZA EL CREDITO
  def get_callback_decline
    @error_desc = []
    @customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless @customer_credit.blank?
      if @customer_credit[0].extra2 > Time.now
        if @customer_credit.blank?
          render json: { message: "No se encontró una solicitud de crédito con el token: #{params[:call_back_token]}", status: false }, status: 206
        else
          # if @customer_credit[0].status == 'PA'
          @customer_credit.update(status: 'RE')
          @customer_credit.update(extra3: "#{params[:call_back_token]}-RE")
          render json: { message: 'Ok, Credito actualizado con exito (RECHAZADO)' }, status: 200
          # else
            # render json: { message: "El credito ya ha sido actualizado por el cliente (#{@customer_credit[0].status})", status: false }, status: 206
          # end

        end
      else
        render json: { message: "Token expiró el #{@customer_credit[0].extra2}", status: false }, status: 206
      end
    else 
      render json: { message: "No encuentra el customer credit", status: false }, status: 206
    end
  end

  def get_callback_token
    @error_desc = []
    customer_credit = CustomerCredit.where(extra3: params[:call_back_token])
    unless customer_credit.blank?
      if customer_credit[0].extra2 > Time.now
          render json: { message: 'Token vigente', status: true }, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: "Token expiró el #{customer_credit[0].extra2}", status: false }, status: 206
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: 'Token de un solo uso ya fué utilizado', status: false }, status: 206
    end
  end

  def get_comitee_callback_token
    @customer_credit_signatory = CustomerCreditsSignatory.where(signatory_token: params[:call_back_token])
    unless @customer_credit_signatory.blank?
      @signatory_token_expiration = @customer_credit_signatory[0].signatory_token_expiration
      if @signatory_token_expiration > Time.now
          render json: { message: 'Token Ok', status: true , credit_id: @customer_credit_signatory[0]["customer_credit_id"]}, status: 200
      else
        #EL TOKEN HA EXPIRADO
        render json: { message: 'Token expiró', status: false }, status: 206
      end
    else
      # NO SE ENCONTRÓ EL TOKEN
      render json: { message: "No se encontró registro", customer_credit_signatory: "#{@customer_credit_signatory[0].inspect}", status: false
        }, status: 206
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

  def update_user
    @user = User.where(reset_password_token: params['reset_password_token'])
      unless @user.blank?
        if @user.update(password: params['password'],reset_password_token: "#{params['reset_password_token']}-utilizado" )
          render json: { message: 'Update ok', status: true , user: @user.inspect}, status: 200
        else
          render json: { message: "Hubo un error al actualizar contraseña", user: "#{@user.inspect}", status: false}, status: 206
        end
      else
        # NO SE ENCONTRÓ EL TOKEN
      render json: { message: "No se encontró registro", user: "#{@user.inspect}", status: false}, status: 206
      end
  end

  def get_reset_pwd_token
    @user_where = User.where(reset_password_token: params[:reset_password_token])
    @user = @user_where[0]
    if @user.blank?
      render json: { message: "No se encontró registro", user: "#{@user.inspect}", status: false}, status: 206
    else
      render json: { message: 'Ok', status: true , user: @user.inspect}, status: 200
    end
  end

  def signature
    # puts params.inspect
    @customer_credit_signatory = CustomerCreditsSignatory.where(signatory_token: params['signatory_token'])
    # @notes = []
    # if @customer_credit_signatory[0].notes.is_a? Enumerable 
      # @notes = @notes + (@customer_credit_signatory[0].notes)    
    # else
      # @notes = [@customer_credit_signatory[0].notes]
    # end

    if @customer_credit_signatory.blank?
        render json: { message: "No se encontró una solicitud de crédito con el token: #{params['signatory_token']}"  }, status: 206
    else
      if @customer_credit_signatory[0].signatory_token_expiration > Time.now
        # if @customer_credit_signatory[0].status == 'PA'
          @customer_credit_signatory.update(status: params['status'])
          @customer_credit_signatory.update(notes: params['comment'])
          # CAMBIA FECHA DE EXPIRACION DEL SIGNATORY_TOKEN
          @customer_credit_signatory.update(signatory_token_expiration: "1990-04-02 02:28:59.692599")

          #METODO QUE ACTUALIZA Y REVISA ESTATUS DEL CREDITO, CUANDO TODOS ESTEN FIRMADOS Y ACEPTADOS DEBE MANDAR CORREO A MESA DE CONTROL
          @signatories = CustomerCreditsSignatory.where(customer_credit_id: @customer_credit_signatory[0].customer_credit_id)
          unless @signatories.blank?
            @arr = []
            @signatories.each do |sign|
              @arr.push sign.status
            end
            @AC = @arr.minmax.reduce(&:eql?) ? true : false        
            if @AC
              # MANDA UN MAIL AL ANALISTA PARA QUE SOLICITE APROBACION DEL CLIENTE
              # send_analyst_mailer(@customer_credit_signatory[0].customer_credit_id)
              #TO DO: MOVER ESTE MAILER AL PUNTO DONDE EL CLIENTE ACEPTA EL CREDITO
              #METODO QUE MANDA NOTIFICACION A MESA DE CONTROL PARA QUE ANALICE A DETALLE EL CREDITO POR APROVAR CUANDO TODOS HAYAN FIRMADO INCLUYENDO AL CLIENTE
              # send_control_desk_mailer( @customer_credit_signatory[0].customer_credit_id)
            end
            render json: { message: 'Ok, Credito actualizado con exito' }, status: 200
          else
            render json: { message: "No se encuentran signatories: #{@customer_credit_signatory[0].status}"  }, status: 206
          end
        # else
          # render json: { message: "El credito ya ha sido actualizado STATUS: #{@customer_credit_signatory[0].status}"  }, status: 206
        # end
      else
        render json: { message: 'Token vencido' }, status: 206
      end
    end
  end

  def terms
    @terms = Term.all
    unless @terms.blank?
    render json: { terms: @terms}, status: 200
    else
      render json: { message: 'No se encontraron condiciones terms' }, status: 206
    end
  end

  def customer_credits
    @customer_credits = CustomerCredit.find(params[:id])
    unless @customer_credits.blank?
    render json: { message: 'Ok', status: true , data: @customer_credits}, status: 200
    else
      render json: { message: 'No se encontraron customer_credits' }, status: 206
    end
  end

  def payment_periods
    @payment_periods = PaymentPeriod.all
    unless @payment_periods.blank?
    render json: { data:@payment_periods }, status: 200
    else
      render json: { message: 'No se encontraron payment_periods' }, status: 206
    end
  end

  def ext_rates
    @ext_rates = ExtRate.all
    unless @ext_rates.blank?
      # @ext_rates
    render json: { message: 'Ok', status: true , data: @ext_rates}, status: 200
    else
      render json: { message: 'No se encontraron ext_rates ext_rates' }, status: 206
    end
  end

  def get_credit_customer_report
    @query = "SELECT cuc.id id_credito, cuc.rate tasa_empleado, cuc.total_requested total_solicitado, cuc.interests total_intereseses, 
    cuc.start_date fecha_credito, cuc.status status_credito, pap.value periodo_pago, 
     cus.id id_cliente, cus.name nombre_cliente, cus.customer_type tipo_cliente, cus.status status_cliente, 
     cus.salary_period, cus.user_id id_usuario, cus.file_type_id id_tipo_expediente, con.id id_contribuyente, 
     con.contributor_type tipo_contribuyente, con.bank banco, con.account_number cuenta_bancaria, con.clabe cuenta_clabe, 
     con.person_id id_persona_fisica, con.legal_entity_id id_persona_moral, peo.fiscal_regime pf_regimen_fiscal, 
     peo.rfc pf_rfc, peo.curp pf_curp, peo.imss pf_numero_seguro_social, peo.first_name || ' ' || peo.last_name || ' ' || peo.second_last_name pf_nombre, 
     peo.gender pf_genero, peo.nationality pf_nacionalidad, peo.birthplace pf_lugar_nacimiento, peo.birthdate pf_fecha_nacimiento, 
     peo.martial_status pf_estado_civil, peo.id_type pf_tipo_identificacion, peo.identification pf_numero_identificacion, 
     peo.phone pf_telefono, peo.mobile pf_celular, peo.email pf_correo, peo.fiel pf_fiel, lee.fiscal_regime pm_regimen_fiscal, 
     lee.rfc pm_rfc, lee.rug pm_rug, lee.business_name pm_nombre, lee.phone pm_telefono, lee.mobile pm_celular, 
     lee.email pm_correo, lee.business_email pm_correo_negocio, lee.main_activity pm_actividad_pricipal, lee.fiel pm_fiel, 
     coa.street calle, coa.suburb suburb, coa.external_number numero_exterior, coa.postal_code codigo_postal,
     sta.name estado, mun.name municipio, cou.name pais, com.business_name
     FROM customer_credits cuc
     JOIN customers cus ON (cus.id = cuc.customer_id)
     JOIN contributors con ON (cus.contributor_id = con.id)
     JOIN payment_periods pap ON (pap.id = cuc.payment_period_id)
     JOIN companies com ON (com.id = cus.company_id)
     LEFT JOIN people peo ON (peo.id = con.person_id)
     LEFT JOIN legal_entities lee ON (lee.id = con.legal_entity_id)
     JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
     JOIN states sta ON (sta.id = coa.state_id)
     JOIN municipalities mun ON (mun.id = coa.municipality_id)
     JOIN countries cou ON (cou.id = sta.country_id)
             WHERE cuc.id = ':customer_credit_id';"
    @query = @query.gsub ':customer_credit_id', params[:customer_credit_id].to_s
    @get_credit_customer_report = execute_statement(@query)
    render json: @get_credit_customer_report
   end

   def sim_customer_payments
    @sim_customer_payment = SimCustomerPayment.where(customer_credit_id: params[:id])
    unless @sim_customer_payment.blank?
      render json: { message: 'Ok', status: true , data: @sim_customer_payment}, status: 200
    else
      render json: { message: "No se encuentra el sim customer payment id = #{params[:id]}", data:[]}, status: 206
    end
  end

   def contributor_documents
    @contributor_documents = ContributorDocument.where( contributor_id: params[:id])
    unless @contributor_documents.blank?
      render json: { message: 'Ok', status: true , data: @contributor_documents}, status: 200
    else
      render json: { message: "No se encuentra el contributor_documents  #{params[:id]}"}, status: 206
    end
  end

  def get_customer
    @query = "SELECT cus.*, con.*, peo.*, coa.*
    FROM customer_credits cuc
    JOIN customers cus ON (cus.id = cuc.customer_id)
    JOIN contributors con ON (cus.contributor_id = con.id)
    LEFT JOIN people peo ON (peo.id = con.person_id)
    JOIN contributor_addresses coa ON (coa.contributor_id = con.id)
    JOIN states sta ON (sta.id = coa.state_id)
    JOIN municipalities mun ON (mun.id = coa.municipality_id)
    JOIN countries cou ON (cou.id = sta.country_id)
    WHERE cuc.id = ':customer_credit_id';"

    @query = @query.gsub ':customer_credit_id', params[:customer_credit_id].to_s
    @get_credit_customer_report = execute_statement(@query)
    render json: @get_credit_customer_report
  end

end
