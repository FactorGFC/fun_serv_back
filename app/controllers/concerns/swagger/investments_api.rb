module Swagger::InvestmentsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/funding_requests/{funding_request_id}/investments' do
      parameter name: :funding_request_id do
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
      # GET /funding_requests/:funding_request_id/investments
      operation :get do
        key :description, 'Trae todas las inversiones de una solicitud de fondeo'
        key :operationId, :find_funding_request_investments
        key :produces, ['application/json']
        key :tags, [:Investment]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :InvestmentOutput
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

    swagger_path '/funding_requests/{funding_request_id}/investments/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :funding_request_id do
        key :in, :path
        key :description, 'ID de la solicitud de fondeo'
        key :required, true
         key :type, :string
        key :format, :uuid 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID de la inversión'
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

      # GET /funding_requests/{funding_request_id}/investments/{id}
      operation :get do
        key :description, 'Busca una inversión de una solicitud de fondeo'
        key :operationId, :find_investment_by_id
        key :produces, ['application/json']
        key :tags, [:Investment]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :InvestmentOutput
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
      # PATCH /funding_requests/{funding_request_id}/investments/{id}
      operation :patch do
        key :description, 'Busca una inversion de una solicitud de fondeo y actualiza el dato enviado'
        key :operationId, :update_investment_by_id
        key :produces, ['application/json']
        key :tags, [:Investment]

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
            key :'$ref', :InvestmentOutput
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
      # DELETE /funding_requests/{funding_request_id}/investments/{id}
      operation :delete do
        key :description, 'Elimina una inversión por su ID'
        key :operationId, :delete_investment_by_id
        key :produces, ['application/json']
        key :tags, [:Investment]

        # definición de las respuestas
        response 200 do
          key :description, 'La inversión fue eliminada'
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

    swagger_path '/funding_requests/{funding_request_id}/investments' do

      # POST /funding_requests/{funding_request_id}/investments
      operation :post do
        key :description, 'Crea una nueva inversión para una solicitud de fondeo'
        key :operationId, :create_investment
        key :produces, ['application/json']
        key :tags, [:Investment]

        # Traemos los parametros
        parameter name: :funding_request_id do
          key :in, :path
          key :description, 'ID del de la solicitud de fondeo. FK FUNDING_REQUESTS'
          key :required, true
           key :type, :string
          key :format, :uuid 
        end

        parameter name: :funder_id do
          key :in, :query
          key :description, 'ID del fondeador. FK FUNDER'
          key :required, true
           key :type, :string
          key :format, :uuid 
        end

        parameter name: :total do
          key :in, :query
          key :description, 'Total de la inversión'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :rate do
          key :in, :query
          key :description, 'Tasa de rendimiento de la inversión'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :investment_date do
          key :in, :query
          key :description, 'Fecha de la inversión'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus de la inversión LV. INVESTMENTS_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['Activa', 'Cancelada', 'Liquidada']
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Documento anexo de la inversión'
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
            key :'$ref', :InvestmentOutput
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