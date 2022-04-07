module Swagger::CustomerPersonalReferencesApi
    extend ActiveSupport::Concern
    include Swagger::Blocks
  
    included do
      include Swagger::ErrorSchema
      
      swagger_path'customers/{customer_id}/customer_personal_references' do
        parameter name: :customer_id do
          key :in, :path
          key :description, 'ID del empleado'
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
        # GET /customers/:customer_id/customer_personal_references
        operation :get do
          key :description, 'Trae las referencias personales del empleado'
          key :operationId, :find_customer_customer_personal_references
          key :produces, ['application/json']
          key :tags, [:CustomerPersonalReference]
  
          # definición de las respuestas
          response 200 do
            key :description, 'Operación correcta'
            schema do
              key :'$ref', :CustomerPersonalReferenceOutput
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
  
      swagger_path '/customer/{customer_id}/customer_personal_refernces/{id}' do
        # definición del parámetros incluidos en el path
        parameter name: :customer_id do
          key :in, :path
          key :description, 'ID del empleado'
          key :required, true
          key :type, :string
          key :format, :uuid  
        end
  
        parameter name: :id do
          key :in, :path
          key :description, 'ID de la referencia personal'
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

        operation :get do
          key :description, 'Busca una referencia personal de un epmpleado'
          key :operationId, :find_customer_personal_reference_by_id
          key :produces, ['application/json']
          key :tags, [:CustomerPersonalReference]
          # definición de las respuestas
          response 200 do
            key :description, 'Operación correcta'
            schema do
              key :'$ref', :SimCustomerPaymentOutput
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

        # PATCH /customer/{customer_id}/customer_customer_personal_references/{id}
        operation :patch do
          key :description, 'Busca una referencia personal del empleado y actualiza su valor'
          key :operationId, :update_customer_personal_reference_by_id
          key :produces, ['application/json']
          key :tags, [:CustomerPersonalReference]
  
          parameter name: :status do
            key :in, :query
            key :description, 'Valor a actualizar'
            key :required, true
            key :type, :string
          end
          # definición de las respuestas
          response 200 do
            key :description, 'Operación correcta'
            schema do
              key :'$ref', :CustomerPersonalReferenceOutput
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
        # DELETE /customer/{customer_id}/customer_personal_reference/{id}
        operation :delete do
          key :description, 'Elimina una referencia personal por su id'
          key :operationId, :delete_customer_personal_reference_by_id
          key :produces, ['application/json']
          key :tags, [:CustomerPersonalReference]
  
          # definición de las respuestas
          response 200 do
            key :description, 'El pago del crédito fue eliminado'
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
  
      swagger_path '/customer/{customer_id}/customer_personal_reference' do
  
        # POST /customer/{customer_id}/customer_personal_reference
        operation :post do
          key :description, 'Crea una nueva referencia personal para el empleado'
          key :operationId, :create_customer_personal_reference
          key :produces, ['application/json']
          key :tags, [:CutomerPersonalReference]
  
          # Traemos los parametros
          parameter name: :customer_id do
            key :in, :path
            key :description, 'ID del empleado. FK CUSTOMERS'
            key :required, true
            key :type, :string
            key :format, :uuid
          end
 
          parameter name: :first_name do
            key :in, :query
            key :description, 'Nombre de la referencia personal'
            key :required, true
            key :type, :string
          end

          parameter name: :last_name do
            key :in, :query
            key :description, 'Primer apellido de la referencia personal'
            key :required, true
            key :type, :string
          end

          parameter name: :second_last_name do
            key :in, :query
            key :description, 'Segundo apellido de la referencia personal'
            key :required, true
            key :type, :string
          end

          parameter name: :address do
            key :in, :query
            key :description, 'Direccion de la referencia personal'
            key :required, true
            key :type, :string
          end

          parameter name: :phone do
            key :in, :query
            key :description, 'Telefono de la referencia personal'
            key :required, true
            key :type, :string
          end

          parameter name: :reference_type do
            key :in, :query
            key :description, 'Tipo de referencia'
            key :required, true
            key :type, :string
            key :enum, ['FAMILIAR', 'NO FAMILIAR']
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
              key :'$ref', :CustomerPersonalReferencetOutput
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