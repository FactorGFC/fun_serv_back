module Swagger::ProjectRequestsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/project_requests' do
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
      # GET /project_requests/
      operation :get do
        key :description, 'Trae todas las solicitudes de proyecto'
        key :operationId, :find_project_requests
        key :produces, ['application/json']
        key :tags, [:ProjectRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ProjectRequestOutput
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

    swagger_path '/project_requests/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID dla solicitud de proyecto'
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

      # GET /project_requests/:id
      operation :get do
        key :description, 'Busca una solicitud de proyecto por su ID'
        key :operationId, :find_project_request_by_id
        key :produces, ['application/json']
        key :tags, [:ProjectRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ProjectRequestOutput
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
      # PATCH /project_requests/:id
      operation :patch do
        key :description, 'Busca una solicitud de proyecto y actualiza el dato enviado'
        key :operationId, :update_project_request_by_id
        key :produces, ['application/json']
        key :tags, [:ProjectRequest]

        parameter name: :project_type do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ProjectRequestOutput
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
      # DELETE /project_requests/:id
      operation :delete do
        key :description, 'Elimina una solicitud de proyecto por su ID'
        key :operationId, :delete_project_request_by_id
        key :produces, ['application/json']
        key :tags, [:ProjectRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'La solicitud de proyecto fue eliminada'
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

    swagger_path '/project_requests' do

      # POST /project_requests
      operation :post do
        key :description, 'Crea una nueva solicitud de proyecto'
        key :operationId, :create_project_request
        key :produces, ['application/json']
        key :tags, [:ProjectRequest]

        # Traemos los parametros
        parameter name: :project_type do
          key :in, :query
          key :description, 'Tipo de solicitud de proyecto LV. PROJECT_REQUEST_PROJECT_TYPE'
          key :required, true
          key :type, :string
          key :enum, ['Credito','Factoraje']
        end

        parameter name: :folio do
          key :in, :query
          key :description, 'Folio de la solicitud de proyecto'
          key :required, true
          key :type, :string
        end

        parameter name: :currency do
          key :in, :query
          key :description, 'Moneda en la que se solicita el proyecto LV. PROJECT_REQUEST_CURRENCY'
          key :required, true
          key :type, :string
          key :enum, ['Pesos','Dólares']
        end

        parameter name: :total do
          key :in, :query
          key :description, 'Total solicitado'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :request_date do
          key :in, :query
          key :description, 'Fecha de solicitud'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus de la solicitud LV. PROJECT_REQUEST_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['En Revisión', 'Aprobada', 'Rechazada', 'Cancelada']
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Anexo de la solicitud'
          key :required, false
          key :type, :string
        end

        parameter name: :customer_id do
          key :in, :query
          key :description, 'Cliente - FK CUSTOMER'
          key :required, true
          key :type, :string
          key :format, :uuid 
        end
        
        parameter name: :user_id do
          key :in, :query
          key :description, 'Usuario - FK USER'
          key :required, true
          key :type, :string
          key :format, :uuid 
        end

        parameter name: :term_id do
          key :in, :query
          key :description, 'Plazo - FK TERM'
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
            key :'$ref', :ProjectRequestOutput
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