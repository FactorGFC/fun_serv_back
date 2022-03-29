module Swagger::ErrorResponses
  # definición de las respuestas de error
  module NotFoundError
    def self.extended(base)
      base.response 404 do
        key :description, 'Recurso no encontrado'
        schema do
          key :'$ref', :ErrorOutput
        end
      end
    end
  end

  module Unauthorized
    def self.extended(base)
      base.response 401 do
        key :description, 'No autorizado'
        schema do
          key :'$ref', :ErrorOutput
        end
      end
    end
  end

  module UnprocessableEntity
    def self.extended(base)
      base.response 422 do
        key :description, 'Parámetros incorrectos'
        schema do
          key :'$ref', :ErrorOutput
        end
      end
    end
  end

  module InternalServerError
    def self.extended(base)
      base.response 500 do
        key :description, 'Error inesperado'
        schema do
          key :'$ref', :ErrorOutput
        end
      end
    end
  end
end