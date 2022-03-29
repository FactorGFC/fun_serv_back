module Swagger::LegalEntitiesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/legal_entities' do
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
      # GET /legal_entities/
      operation :get do
        key :description, 'Trae todo las personas morales'
        key :operationId, :find_legal_entities
        key :produces, ['application/json']
        key :tags, [:LegalEntity]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :LegalEntityOutput
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

    swagger_path '/legal_entities/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la persona moral'
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

      # GET /legal_entities/:id
      operation :get do
        key :description, 'Busca la persona moral por su ID'
        key :operationId, :find_legal_entity_by_id
        key :produces, ['application/json']
        key :tags, [:LegalEntity]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :LegalEntityOutput
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
      # PATCH /legal_entities/:id
      operation :patch do
        key :description, 'Busca una persona moral y actualiza el dato enviado'
        key :operationId, :update_legal_entity_by_id
        key :produces, ['application/json']
        key :tags, [:LegalEntity]

        parameter name: :business_name do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :LegalEntityOutput
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
      # DELETE /legal_entities/:id
      operation :delete do
        key :description, 'Elimina la persona moral por su ID'
        key :operationId, :delete_legal_entity_by_id
        key :produces, ['application/json']
        key :tags, [:LegalEntity]

        # definición de las respuestas
        response 200 do
          key :description, 'La persona fue eliminada'
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

    swagger_path '/legal_entities' do

      # POST /legal_entities
      operation :post do
        key :description, 'Crea una nueva persona'
        key :operationId, :create_legal_entity
        key :produces, ['application/json']
        key :tags, [:LegalEntity]

        # Traemos los parametros
        parameter name: :fiscal_regime do
          key :in, :query
          key :description, 'Regimen fiscal de la persona moral'
          key :required, true
          key :type, :string
          key :enum, ['PERSONA FÍSICA','PERSONA MORAL']
        end

        parameter name: :rfc do
          key :in, :query
          key :description, 'RFC de la persona moral'
          key :required, true
          key :type, :string
        end

        parameter name: :rug do
          key :in, :query
          key :description, 'RUG de la persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :business_name do
          key :in, :query
          key :description, 'Nombre de la persona moral'
          key :required, true
          key :type, :string
        end

        parameter name: :phone do
          key :in, :query
          key :description, 'Teléfono local dela persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :mobile do
          key :in, :query
          key :description, 'Teléfono celular de la persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :email do
          key :in, :query
          key :description, 'Correo electrónico de la persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :business_email do
          key :in, :query
          key :description, 'Correo electrónico de la empresa de la persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :main_activity do
          key :in, :query
          key :description, 'Actividad principal de la persona moral'
          key :required, false
          key :type, :string
        end

        parameter name: :fiel do
          key :in, :query
          key :description, 'FIEL de la persona moral'
          key :required, false
          key :type, :boolean
        end

        parameter name: :extra1 do
          key :in, :query
          key :description, 'Campo extra configurable1 - No debe mostrarse al usuario'
          key :required, false
          key :type, :string
        end

        parameter name: :extra2 do
          key :in, :query
          key :description, 'Campo extra configurable2 - No debe mostrarse al usuario'
          key :required, false
          key :type, :string
        end

        parameter name: :extra3 do
          key :in, :query
          key :description, 'Campo extra configurable3 - No debe mostrarse al usuario'
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
            key :'$ref', :LegalEntityOutput
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