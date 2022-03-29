module Swagger::ProjectsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/projects' do
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
      # GET /projects/
      operation :get do
        key :description, 'Trae todos los proyectos'
        key :operationId, :find_projects
        key :produces, ['application/json']
        key :tags, [:Project]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ProjectOutput
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

    swagger_path '/projects/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del proyecto'
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

      # GET /projects/:id
      operation :get do
        key :description, 'Busca un proyecto por su ID'
        key :operationId, :find_project_by_id
        key :produces, ['application/json']
        key :tags, [:Project]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ProjectOutput
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
      # PATCH /projects/:id
      operation :patch do
        key :description, 'Busca un proyecto y actualiza el dato enviado'
        key :operationId, :update_project_by_id
        key :produces, ['application/json']
        key :tags, [:Project]

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
            key :'$ref', :ProjectOutput
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
      # DELETE /projects/:id
      operation :delete do
        key :description, 'Elimina un proyecto por su ID'
        key :operationId, :delete_project_by_id
        key :produces, ['application/json']
        key :tags, [:Project]

        # definición de las respuestas
        response 200 do
          key :description, 'El proyecto fue eliminado'
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

    swagger_path '/projects' do

      # POST /projects
      operation :post do
        key :description, 'Crea un nuevo proyecto'
        key :operationId, :create_project
        key :produces, ['application/json']
        key :tags, [:Project]

        # Traemos los parametros
        parameter name: :project_type do
          key :in, :query
          key :description, 'Tipo de proyecto LV. PROJECT_PROJECT_TYPE'
          key :required, true
          key :type, :string
          key :enum, ['Credito','Factoraje']
        end

        parameter name: :folio do
          key :in, :query
          key :description, 'Folio del proyecto'
          key :required, true
          key :type, :string
        end

        parameter name: :client_rate do
          key :in, :query
          key :description, 'Tasa para el cliente'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :funder_rate do
          key :in, :query
          key :description, 'Tasa para el inversionista'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :ext_rate do
          key :in, :query
          key :description, 'Tasa externa'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :total do
          key :in, :query
          key :description, 'Importe total del proyecto'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :interests do
          key :in, :query
          key :description, 'Intereses a cobrar por el financiamiento'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :financial_cost do
          key :in, :query
          key :description, 'Costo financiero del financiamiento'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :currency do
          key :in, :query
          key :description, 'Moneda LV. PROJECT_CURRENCY'
          key :required, true
          key :type, :string
          key :enum, ['Pesos','Dólares']
        end

        parameter name: :entry_date do
          key :in, :query
          key :description, 'Fecha de entrada del proyecto'
          key :required, true
          key :type, :string
          key :format, :date
        end

        parameter name: :used_date do
          key :in, :query
          key :description, 'Fecha de operación del proyecto'
          key :required, false
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

        parameter name: :project_request_id do
          key :in, :query
          key :description, 'Solicitud de proyecto - FK PROJECT_REQUESTS'
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

        parameter name: :credit_rating_id do
          key :in, :query
          key :description, 'Calificación de crédito - FK CREDIT_RATING'
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
            key :'$ref', :ProjectOutput
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