module Swagger::GeneralParametersApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/general_parameters' do
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
      # GET /general_parameters/
      operation :get do
        key :description, 'Trae todo los parámetros generales'
        key :operationId, :find_general_parameters
        key :produces, ['application/json']
        key :tags, [:GeneralParameter]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :GeneralParameterOutput
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

    swagger_path '/general_parameters/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del parametro general'
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

      # GET /general_parameters/:id
      operation :get do
        key :description, 'Busca un parametro general por su ID'
        key :operationId, :find_general_parameter_by_id
        key :produces, ['application/json']
        key :tags, [:GeneralParameter]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :GeneralParameterOutput
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
      # PATCH /general_parameters/:id
      operation :patch do
        key :description, 'Busca un parametro general y actualiza el dato enviado'
        key :operationId, :update_general_parameter_by_id
        key :produces, ['application/json']
        key :tags, [:GeneralParameter]

        parameter name: :description do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :GeneralParameterOutput
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
      # DELETE /general_parameters/:id
      operation :delete do
        key :description, 'Elimina un parámetro general por su ID'
        key :operationId, :delete_general_parameter_by_id
        key :produces, ['application/json']
        key :tags, [:GeneralParameter]

        # definición de las respuestas
        response 200 do
          key :description, 'El el parámetro general fué eliminado'
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

    swagger_path '/general_parameters' do

      # POST /general_parameters
      operation :post do
        key :description, 'Crea un nuevo parámetro general'
        key :operationId, :create_general_parameter
        key :produces, ['application/json']
        key :tags, [:GeneralParameter]

        # Traemos los parametros
        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del parámetro general'
          key :required, true
          key :type, :string
        end

        parameter name: :key do
          key :in, :query
          key :description, 'Clave del parámetro general'
          key :required, true
          key :type, :string
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor del parámetro general'
          key :required, true
          key :type, :string
        end

        parameter name: :table do
          key :in, :query
          key :description, 'Tabla parametrizada'
          key :required, false
          key :type, :string
        end

        parameter name: :id_table do
          key :in, :query
          key :description, 'Identificador del registro de la tabla parametrizado'
          key :required, false
          key :type, :string
        end

        parameter name: :used_values do
          key :in, :query
          key :description, 'Posibles valores de la parametrización'
          key :required, false
          key :type, :string
        end

        parameter name: :documentation do
          key :in, :query
          key :description, 'Documentación del uso del parámetro'
          key :required, false
          key :type, :string
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
            key :'$ref', :GeneralParameterOutput
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