module Swagger::RatesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/rates' do
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
      # GET /rates/
      operation :get do
        key :description, 'Trae todas las tasas'
        key :operationId, :find_rates
        key :produces, ['application/json']
        key :tags, [:Rate]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :RateOutput
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

    swagger_path '/rates/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID dla tasa'
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

      # GET /rates/:id
      operation :get do
        key :description, 'Busca una tasa por su ID'
        key :operationId, :find_rate_by_id
        key :produces, ['application/json']
        key :tags, [:Rate]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :RateOutput
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
      # PATCH /rates/:id
      operation :patch do
        key :description, 'Busca una tasa y actualiza el dato enviado'
        key :operationId, :update_rate_by_id
        key :produces, ['application/json']
        key :tags, [:Rate]

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
            key :'$ref', :RateOutput
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
      # DELETE /rates/:id
      operation :delete do
        key :description, 'Elimina una tasa por su ID'
        key :operationId, :delete_rate_by_id
        key :produces, ['application/json']
        key :tags, [:Rate]

        # definición de las respuestas
        response 200 do
          key :description, 'La tasa fue eliminada'
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

    swagger_path '/rates' do

      # POST /rates
      operation :post do
        key :description, 'Crea una nueva tasa'
        key :operationId, :create_rate
        key :produces, ['application/json']
        key :tags, [:Rate]

        # Traemos los parametros
        parameter name: :key do
          key :in, :query
          key :description, 'Clave de la tasa'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción de la tasa'
          key :required, true
          key :type, :string
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor de la tasa'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :term_id do
          key :in, :query
          key :description, 'Identificador del plazo - FK TERM'
          key :required, true
          key :type, :string
          key :format, :uuid 
        end

        parameter name: :payment_period_id do
          key :in, :query
          key :description, 'Periodo de pago - FK PAYMENT_PERIOD'
          key :required, true
          key :type, :string
          key :format, :uuid 
        end

        parameter name: :credit_rating_id do
          key :in, :query
          key :description, 'Calificación de crédito - FK CREDIT_RATING'
          key :required, false
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
            key :'$ref', :RateOutput
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