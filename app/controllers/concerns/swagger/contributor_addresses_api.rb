module Swagger::ContributorAddressesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors/{contributor_id}/contributor_addresses' do
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente. FK CONTRIBUTORS'
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
      # GET /contributors/:contributor_id/contributor_addresses
      operation :get do
        key :description, 'Trae todos los domicilios de un contribuyente'
        key :operationId, :find_contributor_contributor_addresses
        key :produces, ['application/json']
        key :tags, [:ContributorAddress]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorAddressOutput
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

    swagger_path '/contributors/{contributor_id}/contributor_addresses/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente. FK CONTRIBUTORS'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del domicilio'
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

      # GET /contributors/{contributor_id}/contributor_addresses/{id}
      operation :get do
        key :description, 'Busca un domicilio de un contribuyente'
        key :operationId, :find_contributor_address_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorAddress]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorAddressOutput
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
      # PATCH /contributors/{contributor_id}/contributor_addresses/{id}
      operation :patch do
        key :description, 'Busca un domicilio de un contribuyente y actualiza el dato enviado'
        key :operationId, :update_contributor_address_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorAddress]

        parameter name: :address_type do
          key :in, :query
          key :description, 'Domicilio fiscal'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorAddressOutput
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
      # DELETE /contributors/{contributor_id}/contributor_addresses/{id}
      operation :delete do
        key :description, 'Elimina un domicilio por su ID'
        key :operationId, :delete_contributor_address_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorAddress]

        # definición de las respuestas
        response 200 do
          key :description, 'El domicilio fue eliminado'
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

    swagger_path '/contributors/{contributor_id}/contributor_addresses' do

      # POST /contributors/{contributor_id}/contributor_addresses
      operation :post do
        key :description, 'Crea un nuevo domicilio para un contribuyente'
        key :operationId, :create_contributor_address
        key :produces, ['application/json']
        key :tags, [:ContributorAddress]

        # Traemos los parametros
        parameter name: :contributor_id do
          key :in, :path
          key :description, 'ID del contribuyente. FK: CONTRIBUTORS'
          key :required, true
          key :type, :string
        end
        
        parameter name: :municipality_id do
          key :in, :query
          key :description, 'ID del municipio del domicilio. FK MUNICIPALITIES'
          key :required, true
          key :type, :string
        end

        parameter name: :state_id do
          key :in, :query
          key :description, 'ID del estado del domicilio. FK: STATES'
          key :required, true
          key :type, :string
        end

        parameter name: :address_type do
          key :in, :query
          key :description, 'Tipo de domicilio, dominio de LV: contributor_address.address_type'
          key :required, false
          key :type, :string
          key :enum, ['PARTICULAR','FISCAL','OFICINA']
        end

        parameter name: :street do
          key :in, :query
          key :description, 'Calle del domicilio'
          key :required, true
          key :type, :string
        end

        parameter name: :external_number do
          key :in, :query
          key :description, 'Número exterior del domicilio'
          key :required, true
          key :type, :number
        end

        parameter name: :apartment_number do
          key :in, :query
          key :description, 'Número interior del domicilio'
          key :required, false
          key :type, :string
        end

        parameter name: :suburb_type do
          key :in, :query
          key :description, 'Tipo de asentamiento, dominio de LV: contributor_address.suburb_type'
          key :required, false
          key :type, :string
          key :enum, ['URBANO','RUSTICO']
        end

        parameter name: :suburb do
          key :in, :query
          key :description, 'Colonia del domicilio'
          key :required, true
          key :type, :string
        end

        parameter name: :postal_code do
          key :in, :query
          key :description, 'Código postal del domicilio'
          key :required, true
          key :type, :integer
        end

        parameter name: :address_reference do
          key :in, :query
          key :description, 'Referencia de la dirección'
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
            key :'$ref', :ContributorAddressOutput
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