module Swagger::FundersApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors/{contributor_id}/funders' do
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente'
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
      # GET /contributors/:contributor_id/funders
      operation :get do
        key :description, 'Trae todos los inversionistas de un contribuyente'
        key :operationId, :find_contributor_funders
        key :produces, ['application/json']
        key :tags, [:Funder]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FunderOutput
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

    swagger_path '/contributors/{contributor_id}/funders/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente FK: CONTRIBUYENTES'
        key :required, true
        key :type, :string
        key :format, :uuid
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del inversionista'
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

      # GET /contributors/{contributor_id}/funders/{id}
      operation :get do
        key :description, 'Busca una inversionista de un contribuyente'
        key :operationId, :find_funder_by_id
        key :produces, ['application/json']
        key :tags, [:Funder]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FunderOutput
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
      # PATCH /contributors/{contributor_id}/funders/{id}
      operation :patch do
        key :description, 'Busca un inversionista de un contribuyente y actualiza el dato enviado'
        key :operationId, :update_funder_by_id
        key :produces, ['application/json']
        key :tags, [:Funder]

        parameter name: :name do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FunderOutput
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
      # DELETE /contributors/{contributor_id}/funders/{id}
      operation :delete do
        key :description, 'Elimina un inversionista de un contribuyente por su ID'
        key :operationId, :delete_funder_by_id
        key :produces, ['application/json']
        key :tags, [:Funder]

        # definición de las respuestas
        response 200 do
          key :description, 'El inversionista fue eliminado'
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

    swagger_path '/contributors/{contributor_id}/funders' do

      # POST /contributors/{contributor_id}/funders
      operation :post do
        key :description, 'Crea un nuevo inversionista para un contribuyente'
        key :operationId, :create_funder
        key :produces, ['application/json']
        key :tags, [:Funder]

        # Traemos los parametros
        parameter name: :contributor_id do
          key :in, :path
          key :description, 'ID del contribuyente. FK CONTRIBUTORS'
          key :required, true
          key :type, :string
          key :format, :uuid
        end
        
        parameter name: :funder_type do
          key :in, :query
          key :description, 'Tipo de inversionista'
          key :required, true
          key :type, :string
          key :enum, ['PARTICULAR','EMPRESA','BANCO','FINANCIERA']
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del inversionista'
          key :required, true
          key :type, :string
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del inversionista'
          key :required, true
          key :type, :string
          key :enum, ['ACTIVO','INACTIVO', 'BLOQUEADO']
        end

        parameter name: :user_id do
          key :in, :query
          key :description, 'ID del usuario. FK USERS'
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
            key :'$ref', :FunderOutput
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
