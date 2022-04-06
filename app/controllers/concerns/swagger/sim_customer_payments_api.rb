module Swagger::SimCustomerPaymentsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/customer_credits/{customer_credit_id}/sim_customer_payments' do
      parameter name: :customer_credit_id do
        key :in, :path
        key :description, 'ID del crédito'
        key :required, true
        key :type, :string
        key :format, :uuid 
      end
      
      parameter name: :token do
        key :in, :query
        key :description, 'Token del inicio de la sesión del usuario'
        key :required, true
        key :type, :string
      end

      parameter name: :secret_key do
        key :in, :query
        key :description, 'Llave secreta del javascript origins'
        key :required, true
        key :type, :string
      end
      # GET /customer_credits/:customer_credit_id/sim_customer_payments
      operation :get do
        key :description, 'Trae todos los pagos del crédito'
        key :operationId, :find_customer_credit_sim_customer_payments
        key :produces, ['application/json']
        key :tags, [:SimCustomerPayment]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimCustomerPaymentOutput
          end
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
    end

    swagger_path '/customer_credits/{customer_credit_id}/sim_customer_payments/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :customer_credit_id do
        key :in, :path
        key :description, 'ID del crédito'
        key :required, true
        key :type, :string
        key :format, :uuid  
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del pago'
        key :required, true
        key :type, :string
        key :format, :uuid  
      end
 # definición de los parámetros de entrada
      parameter name: :token do
        key :in, :query
        key :description, 'Token del inicio de la sesión del usuario'
        key :required, true
        key :type, :string
      end

      parameter name: :secret_key do
        key :in, :query
        key :description, 'Llave secreta del javascript origins'
        key :required, true
        key :type, :string
      end

      # GET /customer_credits/{customer_credit_id}/sim_customer_payments/{id}
      operation :get do
        key :description, 'Busca un pago de un crédito'
        key :operationId, :find_sim_customer_payment_by_id
        key :produces, ['application/json']
        key :tags, [:SimCustomerPayment]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimCustomerPaymentOutput
          end
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
      # PATCH /customer_credits/{customer_credit_id}/sim_customer_payments/{id}
      operation :patch do
        key :description, 'Busca un pago de un crédito y actualiza el dato enviado'
        key :operationId, :update_sim_customer_payment_by_id
        key :produces, ['application/json']
        key :tags, [:SimCustomerPayment]

        parameter name: :status do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimCustomerPaymentOutput
          end
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
      # DELETE /customer_credits/{customer_credit_id}/sim_customer_payments/{id}
      operation :delete do
        key :description, 'Elimina un pago por su id'
        key :operationId, :delete_sim_customer_payment_by_id
        key :produces, ['application/json']
        key :tags, [:SimCustomerPayment]

        # definición de las respuestas
        response 200 do
          key :description, 'El pago del crédito fue eliminado'
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
    end

    swagger_path '/customer_credits/{customer_credit_id}/sim_customer_payments' do

      # POST /customer_credits/{customer_credit_id}/sim_customer_payments
      operation :post do
        key :description, 'Crea un nuevo pago para un crédito'
        key :operationId, :create_sim_customer_payment
        key :produces, ['application/json']
        key :tags, [:SimCustomerPayment]

        # Traemos los parametros
        parameter name: :customer_credit_id do
          key :in, :path
          key :description, 'ID del crédito. FK CUSTOMER_CREDITS'
          key :required, true
          key :type, :string
          key :format, :uuid
        end

        parameter name: :pay_number do
          key :in, :query
          key :description, 'Número de pago'
          key :required, true
          key :type, :integer          
        end

        parameter name: :current_debt do
          key :in, :query
          key :description, 'Saldo actual'
          key :required, true
          key :type, :number
          key :format, :float
        end
        
        parameter name: :remaining_debt do
          key :in, :query
          key :description, 'Saldo insoluto'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :payment do
          key :in, :query
          key :description, 'Importe del pago'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :capital do
          key :in, :query
          key :description, 'Capital'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :interests do
          key :in, :query
          key :description, 'intereses'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :iva do
          key :in, :query
          key :description, 'Impuesto del valor agregado'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :payment_date do
          key :in, :query
          key :description, 'Fecha programada de pago'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del pago LV. SIM_CUSTOMER_PAYMENTS_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['PENDIENTE', 'PAGADO', 'CANCELADO']
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Documento anexo del pago'
          key :required, false
          key :type, :string
        end

        parameter name: :insurance do
          key :in, :query
          key :description, 'Seguro del crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :commission do
          key :in, :query
          key :description, 'Comisión a pagar por crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :aditional_payment do
          key :in, :query
          key :description, 'Pago adicional que se quiera realizar al crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :token do
          key :in, :query
          key :description, 'Token del inicio de la sesión del usuario'
          key :required, true
          key :type, :string
        end

        parameter name: :secret_key do
          key :in, :query
          key :description, 'Llave secreta del javascript origins'
          key :required, true
          key :type, :string
        end

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimCustomerPaymentOutput
          end
        end
        response 204 do
          key :description, 'Transacción correcta, respuesta sin contenido'
        end
        extend Swagger::ErrorResponses::NotFoundError
        extend Swagger::ErrorResponses::Unauthorized
        extend Swagger::ErrorResponses::UnprocessableEntity
        extend Swagger::ErrorResponses::InternalServerError
      end
    end
  end
end