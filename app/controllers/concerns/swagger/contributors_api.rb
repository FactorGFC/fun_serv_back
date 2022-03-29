module Swagger::ContributorsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors' do
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
      # GET /contributors/
      operation :get do
        key :description, 'Trae todo los contribuyentes'
        key :operationId, :find_contributors
        key :produces, ['application/json']
        key :tags, [:Contributor]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorOutput
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

    swagger_path '/contributors/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del contribuyente'
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

      # GET /contributors/:id
      operation :get do
        key :description, 'Busca un contribuyente por su ID'
        key :operationId, :find_contributor_by_id
        key :produces, ['application/json']
        key :tags, [:Contributor]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorOutput
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
      # PATCH /contributors/:id
      operation :patch do
        key :description, 'Busca un contribuyente y actualiza el dato enviado'
        key :operationId, :update_contributor_by_id
        key :produces, ['application/json']
        key :tags, [:Contributor]

        parameter name: :contributor_type do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorOutput
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
      # DELETE /contributors/:id
      operation :delete do
        key :description, 'Elimina un contribuyente por su ID'
        key :operationId, :delete_contributor_by_id
        key :produces, ['application/json']
        key :tags, [:Contributor]

        # definición de las respuestas
        response 200 do
          key :description, 'El contribuyente fue eliminado'
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

    swagger_path '/contributors' do

      # POST /contributors
      operation :post do
        key :description, 'Crea un nuevo contribuyente'
        key :operationId, :create_contributor
        key :produces, ['application/json']
        key :tags, [:Contributor]

        # Traemos los parametros
        parameter name: :contributor_type do
          key :in, :query
          key :description, 'Tipo de contribuyente, dominio de LV: CONTRIBUTOR.TYPE'
          key :required, true
          key :type, :string
          key :enum, ['PERSONA FÍSICA', 'PERSONA MORAL']
        end

        parameter name: :banco do
          key :in, :query
          key :description, 'Banco del contribuyente'
          key :required, false
          key :type, :string
        end
        
        parameter name: :account_number do
          key :in, :query
          key :description, 'Número de cuenta bancaria del contribuyente'
          key :required, false
          key :type, :integer
          key :format, :bigint 
        end

        parameter name: :clabe do
          key :in, :query
          key :description, 'Número de cuenta clabe del contribuyente'
          key :required, false
          key :type, :integer
          key :format, :bigint 
        end

        parameter name: :person_id do
          key :in, :query
          key :description, 'Identificador de la persona física - FK PEOPLE'
          key :required, false
          key :type, :integer
          key :format, :bigint 
        end

        parameter name: :legal_entity_id do
          key :in, :query
          key :description, 'Identificador de la persona moral - FK LEGAL_ENTITIES'
          key :required, false
          key :type, :integer
          key :format, :bigint 
        end

        parameter name: :extra1 do
          key :in, :query
          key :description, 'Clave de alta en banca en línea'
          key :required, false
          key :type, :string
        end

        parameter name: :extra2 do
          key :in, :query
          key :description, 'Número de proveedores de las cadenas'
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
            key :'$ref', :ContributorOutput
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