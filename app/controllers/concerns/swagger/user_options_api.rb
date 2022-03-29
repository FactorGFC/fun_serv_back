module Swagger::UserOptionsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema

    swagger_path '/user_options/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la asociación del usuario con una opción'
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
      
      # DELETE /user_options/:id
      operation :delete do
        key :description, 'Elimina la asociación de un usuario con una opción'
        key :operationId, :delete_user_option_by_id
        key :produces, ['application/json']
        key :tags, [:UserOption]

        # definición de las respuestas
        response 200 do
          key :description, 'Fue eliminada la asociación de la opción con el usuario'
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

    swagger_path '/user_options' do

      # POST /user_options
      operation :post do
        key :description, 'Asocia una opción con un rol'
        key :operationId, :create_user_option
        key :produces, ['application/json']
        key :tags, [:UserOption]

        # definición de parámetros
        parameter name: :user_id do
          key :in, :query
          key :description, 'Id del usuario. FK USERS'
          key :required, true
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :option_id do
          key :in, :query
          key :description, 'Id de la opción. FK OPTIONS'
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

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserOptionOutput
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