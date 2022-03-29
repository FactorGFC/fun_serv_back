module Swagger::TermsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/terms' do
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
      # GET /terms/
      operation :get do
        key :description, 'Trae todos los servicios externos'
        key :operationId, :find_terms
        key :produces, ['application/json']
        key :tags, [:Term]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :TermOutput
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

    swagger_path '/terms/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del plazo'
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

      # GET /terms/:id
      operation :get do
        key :description, 'Busca un plazo por su ID'
        key :operationId, :find_term_by_id
        key :produces, ['application/json']
        key :tags, [:Term]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :TermOutput
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
      # PATCH /terms/:id
      operation :patch do
        key :description, 'Busca un plazo y actualiza el dato enviado'
        key :operationId, :update_term_by_id
        key :produces, ['application/json']
        key :tags, [:Term]

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
            key :'$ref', :TermOutput
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
      # DELETE /terms/:id
      operation :delete do
        key :description, 'Elimina un plazo por su ID'
        key :operationId, :delete_term_by_id
        key :produces, ['application/json']
        key :tags, [:Term]

        # definición de las respuestas
        response 200 do
          key :description, 'El plazo fue eliminado'
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

    swagger_path '/terms' do

      # POST /terms
      operation :post do
        key :description, 'Crea un nuevo plazo'
        key :operationId, :create_term
        key :produces, ['application/json']
        key :tags, [:Term]

        # definición de los parámtros
        parameter name: :key do
          key :in, :query
          key :description, 'Clave del plazo'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del plazo'
          key :required, true
          key :type, :string
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor del plazo'
          key :required, true
          key :type, :string
        end

        parameter name: :term_type do
          key :in, :query
          key :description, 'Tipo de plazo plazo'
          key :required, true
          key :type, :string
          key :enum, ['Mensual']
        end

        parameter name: :credit_limit do
          key :in, :query
          key :description, 'Límite de crédito para el plazo'
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
            key :'$ref', :TermOutput
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