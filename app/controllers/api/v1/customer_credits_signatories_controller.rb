
class Api::V1::CustomerCreditsSignatoriesController < Api::V1::MasterApiController
    before_action :authenticate
    before_action :set_customer_credit_signatories, only: %i[show update destroy]

    def index
        @customer_credit_signatory = CustomerCreditsSignatory.all
      end

    def show; end

    def create
        @customer_credit_signatory = CustomerCreditsSignatory.new(customer_credit_signatory_params)
        # ActiveRecord::Base.transaction do
        # end
    end

    def update
        @customer_credit_signatory.update(customer_credit_signatory_params)
        render 'api/v1/customer_credits_signatory/show'
      end
    
      def destroy
        @customer_credit_signatory.destroy
        render json: { message: 'Fuéron eliminadas las firmas del credito' }
      end

      # def signature
      #   @error_desc = []
      #   # puts params.inspect
      #   @customer_credit_signatory = CustomerCreditsSignatory.where(signatory_token: params[:signatory_token])
      #   if @customer_credit_signatory[0].signatory_token_expiration > Time.now
      #       if @customer_credit_signatory.blank?
      #           # @error_desc.push("No se encontró una solicitud de crédito con el token: #{params[:signatory_token]}")
      #           # error_array!(@error_desc, :not_found)
      #           render json: { message: "No se encontró una solicitud de crédito con el token: #{params[:signatory_token]}"  }, status: 206
      #       else
      #           if @customer_credit_signatory[0].status == 'PR'
      #           @customer_credit_signatory.update(status: params[:status])
      #           @customer_credit_signatory.update(notes: params[:comment])
      #           @customer_credit_signatory.update(signatory_token_expiration: "1990-04-02 02:28:59.692599")

      #           #METODO QUE ACTUALIZA Y REVISA ESTATUS DEL CREDITO, CUANDO TODOS ESTEN FIRMADOS Y ACEPTADOS DEBE MANDAR CORREO A MESA DE CONTROL
      #           @signatories = CustomerCreditsSignatory.where(customer_credit_id: @customer_credit_signatory[0].customer_credit_id)
      #           @signatories.each do |sign|
      #             @AC = sign.status.eql?("AC") ? true : false
      #           end
      #           if @AC
      #             #TO DO: MANDAR UN MAIL AL ANALISTA PARA QUE SOLICITE APROBACION DEL CLIENTE
      #             send_analyst_mailer
      #             #TO DO: MOVER ESTE MAILER AL PUNTO DONDE EL CLIENTE ACEPTA EL CREDITO
      #             #METODO QUE MANDA NOTIFICACION A MESA DE CONTROL PARA QUE ANALICE A DETALLE EL CREDITO POR APROVAR CUANDO TODOS HAYAN FIRMADO
      #             # send_control_desk_mailer( @customer_credit_signatory[0].customer_credit_id)
      #           end

      #           render json: { message: 'Ok, Credito actualizado con exito' }, status: 200
      #           else
      #           # @error_desc.push("El credito ya ha sido actualizado STATUS: #{@customer_credit_signatory.status}")
      #           # error_array!(@error_desc, :not_found)
      #           render json: { message: "El credito ya ha sido actualizado STATUS: #{@customer_credit_signatory.status}"  }, status: 206
      #           end
      #       end
      #   else
      #     render json: { message: 'Token ya fue utilizado' }, status: 206
      #     # @error_desc.push("El token ha expirado.")
      #     # error_array!(@error_desc, :not_found)
      #   end
      # end

      private

      def set_customer_credit_signatory
        @customer_credit_signatory = CustomerCreditsSignatory.find(params[:id])
      end

      def customer_credit_signatory_params
        # params.require(:customer_credit_signatory).permit(:customer_id,customer_credit_id:,:status)
        params.require(:customer_credit_signatory).permit(:customer_id,:status)
      end

end