module Swagger::UserPrivilegesApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/users/{user_id}/user_privileges' do
      parameter name: :user_id do
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
      # GET /users/:user_id/user_privileges
      operation :get do
        key :description, 'Trae todos los privilegios de un usuario'
        key :operationId, :find_user_user_privileges
        key :produces, ['application/json']
        key :tags, [:UserPrivilege]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserPrivilegeOutput
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

    swagger_path '/users/{user_id}/user_privileges/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :user_id do
        key :in, :path
        key :description, 'ID del usuario'
        key :required, true
        key :type, :integer
        key :format, :bigint 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del privilegio'
        key :required, true
        key :type, :integer
        key :format, :bigint 
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

      # GET /users/{user_id}/user_privileges/{id}
      operation :get do
        key :description, 'Busca un privilegio de un usuario'
        key :operationId, :find_user_privilege_by_id
        key :produces, ['application/json']
        key :tags, [:UserPrivilege]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserPrivilegeOutput
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
      # PATCH /users/{user_id}/user_privileges/{id}
      operation :patch do
        key :description, 'Busca un privilegio de un usuario y actualiza el dato enviado'
        key :operationId, :update_user_privilege_by_id
        key :produces, ['application/json']
        key :tags, [:UserPrivilege]

        parameter name: :description do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :UserPrivilegeOutput
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
      # DELETE /users/{user_id}/user_privileges/{id}
      operation :delete do
        key :description, 'Elimina un usuario por su ID'
        key :operationId, :delete_user_privilege_by_id
        key :produces, ['application/json']
        key :tags, [:UserPrivilege]

        # definición de las respuestas
        response 200 do
          key :description, 'El privilegio fue eliminado'
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

    swagger_path '/users/{user_id}/user_privileges' do

      # POST /users/{user_id}/user_privileges
      operation :post do
        key :description, 'Crea un nuevo privilegio para un usuario'
        key :operationId, :create_user_privilege
        key :produces, ['application/json']
        key :tags, [:UserPrivilege]

        # Traemos los parametros
        parameter name: :user_id do
          key :in, :path
          key :description, 'ID del usuario. FK USERS'
          key :required, true
          key :type, :integer
          key :format, :bigint
        end

        parameter name: :description do
          key :in, :query
          key :description, 'Descripción del privilegio'
          key :required, true
          key :type, :string
          key :enum, ['CAMBIAR_CONTRASEÑA', 'ELIMINAR_FACTURA', 'ELIMINAR_SOLICITUD', 'CREAR_SOLICITUD', 'GENERAR_LAYOUTS']
        end

        parameter name: :value do
          key :in, :query
          key :description, 'Valor del privilegio'
          key :required, true
          key :type, :string
          key :enum, ['SI', 'NO']
        end
        
        parameter name: :key do
          key :in, :query
          key :description, 'Clave del privilegio'
          key :required, true
          key :type, :string
        end

        parameter name: :documentation do
          key :in, :query
          key :description, 'Documentación del parámetro'
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
            key :'$ref', :UserPrivilegeOutput
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