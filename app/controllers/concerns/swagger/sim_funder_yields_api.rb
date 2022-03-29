module Swagger::SimFunderYieldsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/investments/{investment_id}/sim_funder_yields' do
      parameter name: :investment_id do
        key :in, :path
        key :description, 'ID de la inversión'
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
      # GET /investments/:investment_id/sim_funder_yields
      operation :get do
        key :description, 'Trae todos los rendimientos de una inversión'
        key :operationId, :find_investment_sim_funder_yields
        key :produces, ['application/json']
        key :tags, [:SimFunderYield]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimFunderYieldOutput
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

    swagger_path '/investments/{investment_id}/sim_funder_yields/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :investment_id do
        key :in, :path
        key :description, 'ID de la inversión'
        key :required, true
        key :type, :string
        key :format, :uuid  
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del rendimiento'
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

      # GET /investments/{investment_id}/sim_funder_yields/{id}
      operation :get do
        key :description, 'Busca un rendimiento de una inversión'
        key :operationId, :find_sim_funder_yield_by_id
        key :produces, ['application/json']
        key :tags, [:SimFunderYield]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :SimFunderYieldOutput
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
      # PATCH /investments/{investment_id}/sim_funder_yields/{id}
      operation :patch do
        key :description, 'Busca un rendimiento de una inversión y actualiza el dato enviado'
        key :operationId, :update_sim_funder_yield_by_id
        key :produces, ['application/json']
        key :tags, [:SimFunderYield]

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
            key :'$ref', :SimFunderYieldOutput
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
      # DELETE /investments/{investment_id}/sim_funder_yields/{id}
      operation :delete do
        key :description, 'Elimina un rendimiento por su id'
        key :operationId, :delete_sim_funder_yield_by_id
        key :produces, ['application/json']
        key :tags, [:SimFunderYield]

        # definición de las respuestas
        response 200 do
          key :description, 'El rendimiento de la inversión fue eliminada'
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

    swagger_path '/investments/{investment_id}/sim_funder_yields' do

      # POST /investments/{investment_id}/sim_funder_yields
      operation :post do
        key :description, 'Crea un nuevo rendimiento para una inversión'
        key :operationId, :create_sim_funder_yield
        key :produces, ['application/json']
        key :tags, [:SimFunderYield]

        # Traemos los parametros
        parameter name: :investment_id do
          key :in, :path
          key :description, 'ID de la inversion. FK INVESTMENT'
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

        parameter name: :yield_number do
          key :in, :query
          key :description, 'Número de rendimiento'
          key :required, true
          key :type, :integer          
        end

        parameter name: :remaining_capital do
          key :in, :query
          key :description, 'Capital a recuperar'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :capital do
          key :in, :query
          key :description, 'Capital a recuperar'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :gross_yield do
          key :in, :query
          key :description, 'Rendimiento bruto'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :isr do
          key :in, :query
          key :description, 'ISR a descontar del rendimiento'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :net_yield do
          key :in, :query
          key :description, 'Rendimiento neto'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :total do
          key :in, :query
          key :description, 'Total a recibir, capital + rendimiento bruto'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :payment_date do
          key :in, :query
          key :description, 'Fecha programada de pago'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del rendimiento LV. SIM_FUNDER_YIELDS_STATUS'
          key :required, true
          key :type, :string
          key :enum, ['Pendiente', 'Pagado', 'Cancelado']
        end

        parameter name: :attached do
          key :in, :query
          key :description, 'Documento anexo del rendimiento'
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
            key :'$ref', :SimFunderYieldOutput
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