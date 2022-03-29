module Swagger::FileTypeDocumentsApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema

    swagger_path '/file_type_documents/{id}' do
      # definición del parámetro id incluido en el path
      parameter name: :id do
        key :in, :path
        key :description, 'ID de la asociación del tipo expediente con un documento'
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
      
      # DELETE /file_type_documents/:id
      operation :delete do
        key :description, 'Elimina la asociación de un tipo expediente con un documento'
        key :operationId, :delete_file_type_document_by_id
        key :produces, ['application/json']
        key :tags, [:FileTypeDocument]

        # definición de las respuestas
        response 200 do
          key :description, 'Fue eliminada la asociación del documento con el tipo expediente'
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

    swagger_path '/file_type_documents' do

      # POST /file_type_documents
      operation :post do
        key :description, 'Asocia un documento con un tipo expediente'
        key :operationId, :create_file_type_document
        key :produces, ['application/json']
        key :tags, [:FileTypeDocument]

        # definición de parámetros
        parameter name: :file_type_id do
          key :in, :query
          key :description, 'Id del tipo expediente. FK FILE_TYPE'
          key :required, true
          key :type, :string
          key :format, :uuid
        end

        parameter name: :document_id do
          key :in, :query
          key :description, 'Id de la opción. FK DOCUMENT'
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
            key :'$ref', :FileTypeDocumentOutput
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