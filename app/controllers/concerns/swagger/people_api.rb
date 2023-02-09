module Swagger::PeopleApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/people' do
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
      # GET /people/
      operation :get do
        key :description, 'Trae todo las personas físicas'
        key :operationId, :find_people
        key :produces, ['application/json']
        key :tags, [:Person]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PersonOutput
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

    swagger_path '/people/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la persona física'
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

      # GET /people/:id
      operation :get do
        key :description, 'Busca la persona física por su ID'
        key :operationId, :find_person_by_id
        key :produces, ['application/json']
        key :tags, [:Person]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PersonOutput
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
      # PATCH /people/:id
      operation :patch do
        key :description, 'Busca una persona física y actualiza el dato enviado'
        key :operationId, :update_person_by_id
        key :produces, ['application/json']
        key :tags, [:Person]

        parameter name: :first_name do
          key :in, :query
          key :description, 'Valor a actualizar'
          key :required, true
          key :type, :string
        end
        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :PersonOutput
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
      # DELETE /people/:id
      operation :delete do
        key :description, 'Elimina la persona física por su ID'
        key :operationId, :delete_person_by_id
        key :produces, ['application/json']
        key :tags, [:Person]

        # definición de las respuestas
        response 200 do
          key :description, 'La persona fue eliminada'
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

    swagger_path '/people' do

      # POST /people
      operation :post do
        key :description, 'Crea una nueva persona'
        key :operationId, :create_person
        key :produces, ['application/json']
        key :tags, [:Person]

        # Traemos los parametros
        parameter name: :fiscal_regime do
          key :in, :query
          key :description, 'Regimen fiscal de la persona física'
          key :required, true
          key :type, :string
          key :enum, ['PERSONA FÍSICA','PERSONA MORAL']
        end

        parameter name: :rfc do
          key :in, :query
          key :description, 'RFC de la persona física'
          key :required, true
          key :type, :string
        end

        parameter name: :curp do
          key :in, :query
          key :description, 'CURP de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :imss do
          key :in, :query
          key :description, 'Número de seguro social de la persona física'
          key :required, false
          key :type, :integer
        end

        parameter name: :first_name do
          key :in, :query
          key :description, 'Nombre de la persona física'
          key :required, true
          key :type, :string
        end

        parameter name: :last_name do
          key :in, :query
          key :description, 'Primer apellido de la persona física'
          key :required, true
          key :type, :string
        end

        parameter name: :second_last_name do
          key :in, :query
          key :description, 'Segundo apellido de la persona física'
          key :required, true
          key :type, :string
        end

        parameter name: :gender do
          key :in, :query
          key :description, 'Sexo de la persona física'
          key :required, false
          key :type, :string
          key :enum, ['MASCULINO','FEMENINO']
        end

        parameter name: :nationality do
          key :in, :query
          key :description, 'Nacionalidad de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :birth_country do
          key :in, :query
          key :description, 'País de nacimiento de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :birthplace do
          key :in, :query
          key :description, 'Lugar de nacimiento de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :birthdate do
          key :in, :query
          key :description, 'Fecha de nacimiento de la persona física'
          key :required, true
          key :type, :string
          key :format, 'date'
        end

        parameter name: :martial_status do
          key :in, :query
          key :description, 'Estado civil de la persona física'
          key :required, false
          key :type, :string
          key :enum, ['CASADO','SOLTERO']
        end

        parameter name: :martial_regime do
          key :in, :query
          key :description, 'Regimen matrimonial de la persona física'
          key :required, false
          key :type, :string
          key :enum, ['BIENES SEPARADOS','BIENES MANCOMUNADOS']
        end

        parameter name: :minior_dependents do
          key :in, :query
          key :description, 'Dependientes menores de edad de la persona física'
          key :required, false
          key :type, :integer
        end

        parameter name: :senior_depentenents do
          key :in, :query
          key :description, 'Dependientes mayores de edad de la persona física'
          key :required, false
          key :type, :integer
        end

        parameter name: :housing_type do
          key :in, :query
          key :description, 'Tipo de vivienda de la persona física'
          key :required, false
          key :type, :string
          key :enum, ['CASA PROPIA','RENTA']
        end

        parameter name: :id_type do
          key :in, :query
          key :description, 'Tipo de identificación de la persona física'
          key :required, false
          key :type, :string
          key :enum, ['INE','LICENCIA','PASAPORTE']
        end

        parameter name: :identification do
          key :in, :query
          key :description, 'Número de indentificación de la persona física'
          key :required, true
          key :type, :integer
        end

        parameter name: :phone do
          key :in, :query
          key :description, 'Teléfono local dela persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :mobile do
          key :in, :query
          key :description, 'Teléfono celular de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :email do
          key :in, :query
          key :description, 'Correo electrónico de la persona física'
          key :required, false
          key :type, :string
        end

        parameter name: :fiel do
          key :in, :query
          key :description, 'FIEL de la persona física'
          key :required, false
          key :type, :boolean
        end

        parameter name: :extra1 do
          key :in, :query
          key :description, 'Campo extra configurable1 - No debe mostrarse al usuario'
          key :required, false
          key :type, :string
        end

        parameter name: :extra2 do
          key :in, :query
          key :description, 'Campo extra configurable2 - No debe mostrarse al usuario'
          key :required, false
          key :type, :string
        end

        parameter name: :extra3 do
          key :in, :query
          key :description, 'Campo extra configurable3 - No debe mostrarse al usuario - Guardamos el Destino del credito que indique el cliente'
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
            key :'$ref', :PersonOutput
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
