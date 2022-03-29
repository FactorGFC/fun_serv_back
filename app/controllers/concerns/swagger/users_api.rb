module Swagger::UsersApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/users' do
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
      # GET /users/
      operation :get do
        key :description, 'Trae todo los usuarios'
        key :operationId, :find_users
        key :produces, ['application/json']
        key :tags, [:User]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserOutput
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

    swagger_path '/users/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID del usuario'
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

      # GET /users/:id
      operation :get do
        key :description, 'Busca un usuario por su ID'
        key :operationId, :find_user_by_id
        key :produces, ['application/json']
        key :tags, [:User]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserOutput
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
      # PATCH /users/:id
      operation :patch do
        key :description, 'Busca un usuario y actualiza el dato enviado'
        key :operationId, :update_user_by_id
        key :produces, ['application/json']
        key :tags, [:User]

        parameter name: :name do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserOutput
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
      # DELETE /users/:id
      operation :delete do
        key :description, 'Elimina un usuario por su ID'
        key :operationId, :delete_user_by_id
        key :produces, ['application/json']
        key :tags, [:User]

        # definición de las respuestas
        response 200 do
          key :description, 'El usuario fue eliminado'
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

    swagger_path '/users' do

      # POST /users
      operation :post do
        key :description, 'Crea un nuevo usuario'
        key :operationId, :create_user
        key :produces, ['application/json']
        key :tags, [:User]

        # Traemos los parametros
        parameter name: :role_id do
          key :in, :query
          key :description, 'ID del rol del usuario. FK ROLES'
          key :required, false
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :email do
          key :in, :query
          key :description, 'Correo electrónico del usuario'
          key :required, true
          key :type, :string
          key :format, :email 
        end

        parameter name: :password do
          key :in, :query
          key :description, 'Password del usuario'
          key :required, true
          key :type, :string
          key :format, :password
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del usuario'
          key :required, true
          key :type, :string
        end

        parameter name: :job do
          key :in, :query
          key :description, 'Puesto del usuario'
          key :required, false
          key :type, :string
        end

        parameter name: :gender do
          key :in, :query
          key :description, 'Genero del usuario, dominio de LV: USER.GENDER'
          key :required, false
          key :type, :string
          key :enum, ['MASCULINO','FEMENINO']
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del usuario, dominio de LV: USER.ESTATUS'
          key :required, false
          key :type, :string
          key :enum, ['ACTIVO','INACTIVO','SUSPENDIDO']
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
            key :'$ref', :UserOutput
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