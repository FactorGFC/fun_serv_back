module Swagger::CustomerCreditsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/customer_credits' do
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
      # GET /customer_credits/
      operation :get do
        key :description, 'Trae todos creditos al cliente'
        key :operationId, :find_customer_credits
        key :produces, ['application/json']
        key :tags, [:CustomerCredit]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CustomerCreditOutput
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

    swagger_path '/customer_credits/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del credito del ciente'
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

      # GET /customer_credits/:id
      operation :get do
        key :description, 'Busca un credito de cliente por su ID'
        key :operationId, :find_customer_credit_by_id
        key :produces, ['application/json']
        key :tags, [:CustomerCredit]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CustomerCreditOutput
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
      # PATCH /customer_credits/:id
      operation :patch do
        key :description, 'Busca un credito de cliente y actualiza el dato enviado'
        key :operationId, :update_customer_credit_by_id
        key :produces, ['application/json']
        key :tags, [:CustomerCredit]

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
            key :'$ref', :CustomerCreditOutput
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
      # DELETE /customer_credits/:id
      operation :delete do
        key :description, 'Elimina un credito de cliente por su ID'
        key :operationId, :delete_customer_credit_by_id
        key :produces, ['application/json']
        key :tags, [:CustomerCredit]

        # definición de las respuestas
        response 200 do
          key :description, 'El credito del cliente fue eliminado'
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

    swagger_path '/customer_credits' do

      # POST /customer_credits
      operation :post do
        key :description, 'Crea un nuevo credito de cliente'
        key :operationId, :create_customer_credit
        key :produces, ['application/json']
        key :tags, [:CustomerCredit]

        # Traemos los parametros
        parameter name: :total_requested do
          key :in, :query
          key :description, 'Importe total solicitado'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :capital do
          key :in, :query
          key :description, 'Capital a pagar en el crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :interests do
          key :in, :query
          key :description, 'Intereses a pagar en el crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :iva do
          key :in, :query
          key :description, 'IVA a pagar en el crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :total_debt do
          key :in, :query
          key :description, 'Importe a pagar en total al final del crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :fixed_payment do
          key :in, :query
          key :description, 'El pago fijo calculado en la tabla de amortización'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :total_payments do
          key :in, :query
          key :description, 'El total de los pagos que se han hecho al crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :balance do
          key :in, :query
          key :description, 'Saldo, total a pagar menos el total de pagos'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del crédito LV. CUSTOMER_CREDITS_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['Activo', 'Cancelado', 'Rechazado', 'Liquidado']
        end        

        parameter name: :start_date do
          key :in, :query
          key :description, 'Fecha de inicio del crédito'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :end_date do
          key :in, :query
          key :description, 'Fecha fin del crédito'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Anexo de la solicitud'
          key :required, false
          key :type, :string
        end

        parameter name: :customer_id do
          key :in, :query
          key :description, 'Cliente - FK CUSTOMERS'
          key :required, true
          key :type, :string
          key :format, :uuid 
        end
        
        parameter name: :project_id do
          key :in, :query
          key :description, 'Projecto origen del crédito - FK PROJECTS'
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

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CustomerCreditOutput
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