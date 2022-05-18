# frozen_string_literal: true

class Api::V1::PaymentsController < Api::V1::MasterApiController
  #include Swagger::Blocks
  #include Swagger::PaymentsApi

  before_action :authenticate
  before_action :set_payment, only: %i[show update destroy]

  def index
    @payments = Payment.all
  end

  def show; end

  def create
    @error_desc = []
    @payment_credits_mailer = ""
    @payment = Payment.new(payments_params)
    ActiveRecord::Base.transaction do
      if @payment.save
        credit_id = params[:credit_id]
        if credit_id.blank?
          @error_desc.push('Se tiene que mandar el credito asociado al pago')
          @resp_credit = :unprocessable_entity
        else
         @customer_credits = CustomerCredit.where(id: credit_id)
          @customer_credit = @customer_credits[0]
          if@customer_credit.blank?
            @error_desc.push("No se encontró el credito con id: #{credit_id}")
            @resp_credit = :not_found
          else
            pc_type = 'PAGO EMPLEADO'
            total_requested = @customer_credit.total_requested
            @payment_credit = PaymentCredit.custom_update_or_create(@payment, @customer_credit, pc_type, total_requested)
          end

          @payment_credits_mailer = '1'
            #####@payment_invoices_mailer + "#{@credit.folio}, "

        end
        if @resp_credit.blank?
          if @payment_credit.save
       
             # send_mail_to_supplier                 
            render 'api/v1/payments/show'
          else
            error_array!(@payment_credit.errors.full_messages, :unprocessable_entity)
            raise ActiveRecord::Rollback
          end
        else
          error_array!(@error_desc, @resp_credit)
          raise ActiveRecord::Rollback
        end
      else
        error_array!(@payment.errors.full_messages, :unprocessable_entity)
        raise ActiveRecord::Rollback
      end
    end
  end
  

  def update
    if @payment.update(payments_params)
      render 'api/v1/payments/show'
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @payment.destroy
    render json: { message: 'Fué eliminado el pago indicado' }
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payments_params
    params.require(:payment).permit(:payment_date, :payment_type, :payment_number, :currency, :amount, :email_cfdi, :notes, :voucher, :contributor_from_id, :contributor_to_id)
  end

  def send_mail_to_supplier
    # email, name, subject, title, content
    get_contributor_to
    if @mailer_mode == 'TEST'
      @email_to = @mailer_test_email
    end
    @fin_name = GeneralParameter.get_general_parameter_value('NOMBRE_FINANCIERA')
    SendMailMailer.send_email(@email_to,
                              @name_to,
                              "FactorGFC - Confirmación de pago de credito: #{@payment_invoices_mailer}",
                              "Pago de factura",
                              "le informamos que la financiera: #{@fin_name} hizo el pago de las facturas con folio: #{@payment_credits_mailer} 
                              por medio de la operación: #{payments_params[:payment_number]}, con el siguiente comentario: #{payments_params[:notes]}.").deliver_now
  end

  def get_contributor_to
    @contributor_to = Contributor.where(id: payments_params[:contributor_to_id])
    if @contributor_to.blank?
      @error_desc.push("No se encontró el contribuyente destino con id: #{payments_params[:contributor_to_id].to_s}")
      error_array!(@error_desc, :not_found)
      raise ActiveRecord::Rollback
    end
    if @contributor_to[0].contributor_type == 'PERSONA MORAL'
      @legal_entity_to = LegalEntity.where(id: @contributor_to[0].legal_entity_id)
      if @legal_entity_to.blank?
        @error_desc.push("No se encontró la persona moral destino con el id: #{@contributor_to[0].legal_entity_id.to_s}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        @contributor_to_fiel = @legal_entity_to[0].fiel
        @rfc_to = @legal_entity_to[0].rfc
        @name_to = @legal_entity_to[0].business_name
        @api_key_to = @legal_entity_to[0].extra1
        @token_to = @legal_entity_to[0].extra2
        @authorization_to = @legal_entity_to[0].extra3
        @email_to = @legal_entity_to[0].business_email
      end      
    else
      @person_to = Person.where(id: @contributor_to[0].person_id)
      if @person_to.blank?
        @error_desc.push("No se encontró la persona física destino con el id: #{@contributor_to[0].person_id.to_s}")
        error_array!(@error_desc, :not_found)
        raise ActiveRecord::Rollback
      else
        @contributor_to_fiel = @person_to[0].fiel
        @rfc_to = @person_to[0].rfc
        @name_to = "#{@person_to[0].first_name}" "#{@person_to[0].last_name}" "#{@person_to[0].second_last_name}"
        @api_key_to = @person_to[0].extra1
        @token_to = @person_to[0].extra2
        @authorization_to = @person_to[0].extra3
        @email_to = @person_to[0].email
      end
    end
  end


end
