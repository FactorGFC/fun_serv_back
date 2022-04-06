module Swagger::CreditAnalysesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/credit_analyses' do
      parameter name: :customer_credit_id do
        key :in, :path
        key :description, 'ID de la solicitud de credito'
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

      operation :get do
        key :description, 'Trae todos los anilisis de los creditos'
        key :operationId, :find_credit_analyses
        key :produces, ['application/json']
        key :tags, [:CreditAnalysis]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditAnalysisOutput
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

    swagger_path '/credit_analyses/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :customer_credit_id do
        key :in, :path
        key :description, 'ID de la soliccitud del credito'
        key :required, true
        key :type, :string
        key :format, :uuid
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del analisis de la solicitud'
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
        key :description, 'Busca un analisis de una solicitud'
        key :operationId, :find_credit_analysis_by_id
        key :produces, ['application/json']
        key :tags, [:CreditAnalysis]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditAnalysisOutput
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
      operation :patch do
        key :description, 'Busca un analisis de una solicitud de credito y actualiza su valor'
        key :operationId, :update_credit_analysis_by_id
        key :produces, ['application/json']
        key :tags, [:CreditAnalysis]

        parameter name: :credit_ststus do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditAnalysisOutput
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

      operation :delete do
        key :description, 'Elimina un analisis de una solicitud de credito por su ID'
        key :operationId, :delete_credit_analysis_by_id
        key :produces, ['application/json']
        key :tags, [:CreditAnalysis]

        # definición de las respuestas
        response 200 do
          key :description, 'El analisis fue eliminado'
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

    swagger_path '/credit_analysis' do

      # POST /contributors/{contributor_id}/customers
      operation :post do
        key :description, 'Crea un nuevo analisis para una solicitud de credito'
        key :operationId, :create_credit_analysis
        key :produces, ['application/json']
        key :tags, [:CreditAnalysis]

        # Traemos los parametros

        parameter name: :debt_rate do
          key :in, :query
          key :description, 'Indice de endeudamiento del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :cash_flow do
          key :in, :query
          key :description, 'Flujo (egresos vs ingresos) del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :credit_status do
          key :in, :query
          key :description, 'Calificacion de buro de credito del empleado'
          key :required, true
          key :type, :string
        end

        parameter name: :previus_credit do
          key :in, :query
          key :description, 'Credito solicitado mas de 3 meses de sueldo'
          key :required, false
          key :type, :string
          key :enum, ['SI', 'NO']
        end

        parameter name: :discounts do
          key :in, :query
          key :description, 'Descuentos exceden 30%'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :debt_horizon do
          key :in, :query
          key :description, 'Duracion de la deuda en años'
          key :required, false
          key :type, :number
          key :format, :float
        end
        parameter name: :report_date do
          key :in, :query
          key :description, 'Fecha del reporte de Buro de credito'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :mop_key do
          key :in, :query
          key :description, 'Clave MOP del Buro de credito'
          key :required, true
          key :type, :string
        end

        parameter name: :last_key do
          key :in, :query
          key :description, 'Ultima clave reportada de Buro de credito'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :balance_due do
          key :in, :query
          key :description, 'Deuda del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :payment_capacity do
          key :in, :query
          key :description, 'Capacidad de pago del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :lowest_key do
          key :in, :query
          key :description, 'Clave mas baja reportada de Buro de credito'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :departamental_credit do
          key :in, :query
          key :description, 'Creditos de tarjetas departamentales'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :car_credit do
          key :in, :query
          key :description, 'Credito Automotriz'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :mortagage_loan do
          key :in, :query
          key :description, 'Credito hipotecario'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :other_credits do
          key :in, :query
          key :description, 'Otros creditos'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :accured_liabilities do
          key :in, :query
          key :description, 'Total de pasivos'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :debt do
          key :in, :query
          key :description, 'Deuda del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :net_flow do
          key :in, :query
          key :description, 'Flujo neto'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :customer_credit do
          key :in, :query
          key :description, 'Credito del empledo - FK CUSTOMER_CREDITS'
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
            key :'$ref', :CustomerOutput
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
