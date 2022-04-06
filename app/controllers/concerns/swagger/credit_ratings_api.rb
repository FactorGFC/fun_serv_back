module Swagger::CreditRatingsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/credit_ratings' do
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
      # GET /credit_ratings/
      operation :get do
        key :description, 'Trae todas las calificaciones del credito'
        key :operationId, :find_credit_ratings
        key :produces, ['application/json']
        key :tags, [:CreditRating]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditRatingOutput
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

    swagger_path '/credit_ratings/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la calificación de crédito'
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

      # GET /credit_ratings/:id
      operation :get do
        key :description, 'Busca una calificación de crédito por su ID'
        key :operationId, :find_credit_rating_by_id
        key :produces, ['application/json']
        key :tags, [:CreditRating]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditRatingOutput
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
      # PATCH /credit_ratings/:id
      operation :patch do
        key :description, 'Busca una calificación de crédito y actualiza el dato enviado'
        key :operationId, :update_credit_rating_by_id
        key :produces, ['application/json']
        key :tags, [:CreditRating]

        parameter name: :key do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :CreditRatingOutput
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
      # DELETE /credit_ratings/:id
      operation :delete do
        key :description, 'Elimina una calificación de crédito por su ID'
        key :operationId, :delete_credit_rating_by_id
        key :produces, ['application/json']
        key :tags, [:CreditRating]

        # definición de las respuestas
        response 200 do
          key :description, 'La calificación de crédito fue eliminada'
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

    swagger_path '/credit_ratings' do

      # POST /credit_ratings
      operation :post do
        key :description, 'Crea una nueva calificación de crédito'
        key :operationId, :create_credit_rating
        key :produces, ['application/json']
        key :tags, [:CreditRating]

        # definición de los parámtros
        parameter name: :key do
          key :in, :query
          key :description, 'Clave de la calificación de crédito'
          key :required, true
          key :type, :string
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción de la calificación de crédito'
          key :required, true
          key :type, :string
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor de la calificación de crédito'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :cr_type do
          key :in, :query
          key :description, 'Tipo de calificacion de crédito'
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
            key :'$ref', :CreditRatingOutput
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