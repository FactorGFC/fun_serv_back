module Swagger::ExtRatesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/ext_rates' do
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
      # GET /ext_rates/
      operation :get do
        key :description, 'Trae todas las tarifas'
        key :operationId, :find_ext_rates
        key :produces, ['application/json']
        key :tags, [:ExtRate]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ExtRateOutput
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

    swagger_path '/ext_rates/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del la tarifa'
        key :required, true
        key :type, :integer
        key :format, :bigint 
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

      # GET /ext_rates/:id
      operation :get do
        key :description, 'Busca una tarifa por su ID'
        key :operationId, :find_ext_rate_by_id
        key :produces, ['application/json']
        key :tags, [:ExtRate]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ExtRateOutput
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
      # PATCH /ext_rates/:id
      operation :patch do
        key :description, 'Busca una tarifa y actualiza el dato enviado'
        key :operationId, :update_ext_rate_by_id
        key :produces, ['application/json']
        key :tags, [:ExtRate]

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
            key :'$ref', :ExtRateOutput
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
      # DELETE /ext_rates/:id
      operation :delete do
        key :description, 'Elimina una tarifa por su ID'
        key :operationId, :delete_ext_rate_by_id
        key :produces, ['application/json']
        key :tags, [:ExtRate]

        # definición de las respuestas
        response 200 do
          key :description, 'La tarifa fue eliminada'
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

    swagger_path '/ext_rates' do

      # POST /ext_rates
      operation :post do
        key :description, 'Crea una nueva tarifa'
        key :operationId, :create_ext_rate
        key :produces, ['application/json']
        key :tags, [:ExtRate]

        # Traemos los parametros
        parameter name: :key do
          key :in, :query
          key :description, 'Clave de la tarifa [AGRUPADOR]'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción de la tarifa'
          key :required, true
          key :type, :string
        end

        parameter name: :start_date do
          key :in, :query
          key :description, 'Fecha inicio de la tarifa'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :end_date do
          key :in, :query
          key :description, 'Fecha fin de la tarifa'
          key :required, false
          key :type, :string
          key :format, :date
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor de la tarifa'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :rate_type do
          key :in, :query
          key :description, 'Tipo de tarifa'
          key :required, true
          key :type, :string
          key :enum, ['TIIE_28D','LIBOR_1M','IVA']
        end

        parameter name: :max_value do
          key :in, :query
          key :description, 'Valor maximo de una tarifa'
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
            key :'$ref', :ExtRateOutput
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
