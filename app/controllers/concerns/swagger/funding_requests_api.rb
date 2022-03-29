module Swagger::FundingRequestsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/funding_requests' do
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
      # GET /funding_requests/
      operation :get do
        key :description, 'Trae todos las solicitudes de fondeo'
        key :operationId, :find_funding_requests
        key :produces, ['application/json']
        key :tags, [:FundingRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FundingRequestOutput
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

    swagger_path '/funding_requests/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la solicitud de fondeo'
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

      # GET /funding_requests/:id
      operation :get do
        key :description, 'Busca una solicitud de fondeo por su ID'
        key :operationId, :find_funding_request_by_id
        key :produces, ['application/json']
        key :tags, [:FundingRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FundingRequestOutput
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
      # PATCH /funding_requests/:id
      operation :patch do
        key :description, 'Busca una solicitud de fondeo y actualiza el dato enviado'
        key :operationId, :update_funding_request_by_id
        key :produces, ['application/json']
        key :tags, [:FundingRequest]

        parameter name: :funding_request_type do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :FundingRequestOutput
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
      # DELETE /funding_requests/:id
      operation :delete do
        key :description, 'Elimina una solicitud de fondeo por su ID'
        key :operationId, :delete_funding_request_by_id
        key :produces, ['application/json']
        key :tags, [:FundingRequest]

        # definición de las respuestas
        response 200 do
          key :description, 'La solicitud de fondeo fue eliminado'
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

    swagger_path '/funding_requests' do

      # POST /funding_requests
      operation :post do
        key :description, 'Crea una solicitud de fondeo'
        key :operationId, :create_funding_request
        key :produces, ['application/json']
        key :tags, [:FundingRequest]

        # Traemos los parametros
        parameter name: :total_requested do
          key :in, :query
          key :description, 'Total a fondear solicitado'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :total_investments do
          key :in, :query
          key :description, 'Total invertido'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :balance do
          key :in, :query
          key :description, 'Saldo, total a fondear menos total invertido'
          key :required, true
          key :type, :number
          key :format, :float
        end
        
        parameter name: :funding_request_date do
          key :in, :query
          key :description, 'Fecha de la solicitud de fondeo'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :due_date do
          key :in, :query
          key :description, 'Fecha límite para el fondeo'
          key :required, false
          key :type, :string
          key :format, :date
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus de la solicitud de fondeo LV. FUNDING_REQUESTS_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['Activa', 'Fondeada', 'No completada', 'Cancelada']
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Anexo de la solicitud'
          key :required, false
          key :type, :string
        end

        parameter name: :project_id do
          key :in, :query
          key :description, 'Projecto - FK PROJECTS'
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
            key :'$ref', :FundingRequestOutput
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