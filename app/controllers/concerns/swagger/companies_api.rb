module Swagger::CompaniesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors/{contributor_id}/companies' do
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del usuario'
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
      # GET /contributors/:contributor_id/companies
      operation :get do
        key :description, 'Trae todas las cadenas de un contribuyente'
        key :operationId, :find_contributor_companies
        key :produces, ['application/json']
        key :tags, [:Company]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CompanyOutput
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

    swagger_path '/contributors/{contributor_id}/companies/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente FK: CONTRIBUYENTES'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID de la cadena'
        key :required, true
        key :type, :integer
        key :format, :bigint 
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

      # GET /contributors/{contributor_id}/companies/{id}
      operation :get do
        key :description, 'Busca una cadena de un contribuyente'
        key :operationId, :find_company_by_id
        key :produces, ['application/json']
        key :tags, [:Company]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CompanyOutput
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
      # PATCH /contributors/{contributor_id}/companies/{id}
      operation :patch do
        key :description, 'Busca una cadena de un contribuyente y actualiza el dato enviado'
        key :operationId, :update_company_by_id
        key :produces, ['application/json']
        key :tags, [:Company]

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
            key :'$ref', :CompanyOutput
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
      # DELETE /contributors/{contributor_id}/companies/{id}
      operation :delete do
        key :description, 'Elimina una cadena de un contribuyente por su ID'
        key :operationId, :delete_company_by_id
        key :produces, ['application/json']
        key :tags, [:Company]

        # definición de las respuestas
        response 200 do
          key :description, 'La cadena fue eliminada'
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

    swagger_path '/contributors/{contributor_id}/companies' do

      # POST /contributors/{contributor_id}/companies
      operation :post do
        key :description, 'Crea una nueva cadena para un contribuyente'
        key :operationId, :create_company
        key :produces, ['application/json']
        key :tags, [:Company]

        # Traemos los parametros
        parameter name: :contributor_id do
          key :in, :path
          key :description, 'ID del contribuyente. FK CONTRIBUTORS'
          key :required, true
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :business_name do
          key :in, :query
          key :description, 'Nombre del negocio'
          key :required, true
          key :type, :string
        end
        
        parameter name: :start_date do
          key :in, :query
          key :description, 'Fecha de afiliación'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :credit_limit do
          key :in, :query
          key :description, 'Límite de la línea de crédito. precision: 15, scale: 4'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :credit_available do
          key :in, :query
          key :description, 'Crédito disponible de la línea de crédito. precision: 15, scale: 4'
          key :required, true
          key :type, :number
          key :format, :float
        end
        
        parameter name: :document do
          key :in, :query
          key :description, 'Documentos anexos de la cadena'
          key :required, false
          key :type, :string
        end

        parameter name: :sector do
          key :in, :query
          key :description, 'Sector productivo de la cadena'
          key :required, false
          key :type, :string
          key :enum, ['CONSTRUCCION','COMERCIO AL POR MAYOR', '....']
        end

        parameter name: :subsector do
          key :in, :query
          key :description, 'Subsector productivo de la cadena'
          key :required, false
          key :type, :string
          key :enum, ['EDIFICACIÓN','CONSTRUCCIÓN DE OBRAS DE INGENIERÍA CIVIL', '....']
        end

        parameter name: :company_rate do
          key :in, :query
          key :description, 'Tasa de interes de la cadena'
          key :required, false
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
            key :'$ref', :CompanyOutput
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
