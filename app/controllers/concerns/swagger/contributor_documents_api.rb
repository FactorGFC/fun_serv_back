module Swagger::ContributorDocumentsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors/{contributor_id}/contributor_documents' do
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del  contribuyente'
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
      # GET /contributors/:contributor_id/contributor_documents
      operation :get do
        key :description, 'Trae todos los documentos del  contribuyente'
        key :operationId, :find_contributor_contributor_documents
        key :produces, ['application/json']
        key :tags, [:ContributorDocument]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorDocumentOutput
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

    swagger_path '/contributors/{contributor_id}/contributor_documents/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del  contribuyente FK: SUPPLIERS'
        key :required, true
        key :type, :string
        key :format, :uuid 
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del documento'
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

      # GET /contributors/{contributor_id}/contributor_documents/{id}
      operation :get do
        key :description, 'Busca un documento de un contribuyente'
        key :operationId, :find_contributor_document_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorDocument]

        # definición de las respuestas
        response 200 do
          key :description, 'Operación correcta'
          schema do
            key :'$ref', :ContributorDocumentOutput
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
      # PATCH /contributors/{contributor_id}/contributor_documents/{id}
      operation :patch do
        key :description, 'Busca un documento de un contribuyente y actualiza el dato enviado'
        key :operationId, :update_contributor_document_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorDocument]

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
            key :'$ref', :ContributorDocumentOutput
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
      # DELETE /contributors/{contributor_id}/contributor_documents/{id}
      operation :delete do
        key :description, 'Elimina un documento de un contribuyente por su ID'
        key :operationId, :delete_contributor_document_by_id
        key :produces, ['application/json']
        key :tags, [:ContributorDocument]

        # definición de las respuestas
        response 200 do
          key :description, 'El documento fue eliminado'
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

    swagger_path '/contributors/{contributor_id}/contributor_documents' do

      # POST /contributors/{contributor_id}/contributor_documents
      operation :post do
        key :description, 'Crea un nuevo documento para un contribuyente'
        key :operationId, :create_contributor_document
        key :produces, ['application/json']
        key :tags, [:ContributorDocument]

        # Traemos los parametros
        parameter name: :contributor_id do
          key :in, :path
          key :description, 'ID del  contribuyente. FK CONTRIBUTOR'
          key :required, true
          key :type, :string
          key :format, :uuid
        end

        parameter name: :file_type_document_id do
          key :in, :query
          key :description, 'ID del tipo de expediente. FK FILE_TYPE'
          key :required, true
          key :type, :string
          key :format, :uuid
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del documento'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus de revisión del documento'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :notes do
          key :in, :query
          key :description, 'Notas de la revisión del documento'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :url do
          key :in, :query
          key :description, 'URL pública donde está guardado el documento'
          key :required, false
          key :type, :integer
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
            key :'$ref', :ContributorDocumentOutput
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
