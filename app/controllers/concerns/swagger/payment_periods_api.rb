module Swagger::PaymentPeriodsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/payment_periods' do
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
      # GET /payment_periods/
      operation :get do
        key :description, 'Trae todos los servicios externos'
        key :operationId, :find_payment_periods
        key :produces, ['application/json']
        key :tags, [:PaymentPeriod]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PaymentPeriodOutput
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

    swagger_path '/payment_periods/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del periodo de pago'
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

      # GET /payment_periods/:id
      operation :get do
        key :description, 'Busca un periodo de pago por su ID'
        key :operationId, :find_payment_period_by_id
        key :produces, ['application/json']
        key :tags, [:PaymentPeriod]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PaymentPeriodOutput
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
      # PATCH /payment_periods/:id
      operation :patch do
        key :description, 'Busca un periodo de pago y actualiza el dato enviado'
        key :operationId, :update_payment_period_by_id
        key :produces, ['application/json']
        key :tags, [:PaymentPeriod]

        parameter name: :key do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PaymentPeriodOutput
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
      # DELETE /payment_periods/:id
      operation :delete do
        key :description, 'Elimina un periodo de pago por su ID'
        key :operationId, :delete_payment_period_by_id
        key :produces, ['application/json']
        key :tags, [:PaymentPeriod]

        # definición de las respuestas
        response 200 do
          key :description, 'El periodo de pago fue eliminado'
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

    swagger_path '/payment_periods' do

      # POST /payment_periods
      operation :post do
        key :description, 'Crea un nuevo periodo de pago'
        key :operationId, :create_payment_period
        key :produces, ['application/json']
        key :tags, [:PaymentPeriod]

        # definición de los parámtros
        parameter name: :key do
          key :in, :query
          key :description, 'Clave del periodo de pago'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del periodo de pago'
          key :required, true
          key :type, :string
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor del periodo de pago'
          key :required, true
          key :type, :integer
        end

        parameter name: :pp_type do
          key :in, :query
          key :description, 'Tipo periodo de pago'
          key :required, false
          key :type, :string
          key :enum, ['1','4','2']
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
            key :'$ref', :PaymentPeriodOutput
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