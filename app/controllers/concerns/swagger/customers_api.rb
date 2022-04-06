module Swagger::CustomersApi
  extend ActiveSupport::Concern
  include Swagger::Blocks

  included do
    include Swagger::ErrorSchema
    
    swagger_path '/contributors/{contributor_id}/customers' do
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente'
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
      # GET /contributors/:contributor_id/customers
      operation :get do
        key :description, 'Trae todos los clientes de un contribuyente'
        key :operationId, :find_contributor_customers
        key :produces, ['application/json']
        key :tags, [:Customer]

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

    swagger_path '/contributors/{contributor_id}/customers/{id}' do
      # definición del parámetros incluidos en el path
      parameter name: :contributor_id do
        key :in, :path
        key :description, 'ID del contribuyente FK: CONTRIBUYENTES'
        key :required, true
        key :type, :string
        key :format, :uuid
      end

      parameter name: :id do
        key :in, :path
        key :description, 'ID del cliente'
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

      # GET /contributors/{contributor_id}/customers/{id}
      operation :get do
        key :description, 'Busca una cliente de un contribuyente'
        key :operationId, :find_customer_by_id
        key :produces, ['application/json']
        key :tags, [:Customer]

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
      # PATCH /contributors/{contributor_id}/customers/{id}
      operation :patch do
        key :description, 'Busca un cliente de un contribuyente y actualiza el dato enviado'
        key :operationId, :update_customer_by_id
        key :produces, ['application/json']
        key :tags, [:Customer]

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
      # DELETE /contributors/{contributor_id}/customers/{id}
      operation :delete do
        key :description, 'Elimina un cliente de un contribuyente por su ID'
        key :operationId, :delete_customer_by_id
        key :produces, ['application/json']
        key :tags, [:Customer]

        # definición de las respuestas
        response 200 do
          key :description, 'El cliente fue eliminado'
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

    swagger_path '/contributors/{contributor_id}/customers' do

      # POST /contributors/{contributor_id}/customers
      operation :post do
        key :description, 'Crea un nuevo cliente para un contribuyente'
        key :operationId, :create_customer
        key :produces, ['application/json']
        key :tags, [:Customer]

        # Traemos los parametros
        parameter name: :contributor_id do
          key :in, :path
          key :description, 'ID del contribuyente. FK CONTRIBUTORS'
          key :required, true
          key :type, :string
          key :format, :uuid
        end
        
        parameter name: :customer_type do
          key :in, :query
          key :description, 'Tipo de cliente'
          key :required, true
          key :type, :string
        end

        parameter name: :name do
          key :in, :query
          key :description, 'Nombre del cliente'
          key :required, true
          key :type, :string
        end

        parameter name: :status do
          key :in, :query
          key :description, 'Estatus del cliente'
          key :required, true
          key :type, :string
          key :enum, ['ACTIVO','INACTIVO', 'BLOQUEADO']
        end

        parameter name: :salary do
          key :in, :query
          key :description, 'Sueldo del empleado'
          key :required, true
          key :type, :number
          key :format, :float
        end

        parameter name: :salary_period do
          key :in, :query
          key :description, 'Periodo del sueldo'
          key :required, true
          key :type, :string
        end

        parameter name: :other_income do
          key :in, :query
          key :description, 'Otros ingresos del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :net_expenses do
          key :in, :query
          key :description, 'Gastos totales del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :family_expenses do
          key :in, :query
          key :description, 'Gastos familiares del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :house_rent do
          key :in, :query
          key :description, 'Gasto de renta del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :credit_cp do
          key :in, :query
          key :description, 'Creditos de tarjetas de credito bancarias del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :credit_lp do
          key :in, :query
          key :description, 'Total de creditos personales del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :immediate_superior do
          key :in, :query
          key :description, 'Jefe inmediato del empleado'
          key :required, false
          key :type, :string
        end

        parameter name: :seniority do
          key :in, :query
          key :description, 'Antiguedad del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :ontime_bonus do
          key :in, :query
          key :description, 'Bonus de puntualidad'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :assist_bonus do
          key :in, :query
          key :description, 'Bono de asistencia'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :food_vouchers do
          key :in, :query
          key :description, 'Vales de despensa'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :total_income do
          key :in, :query
          key :description, 'Total de ingresos del empleado'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :total_savings_found do
          key :in, :query
          key :description, 'Total fondo de ahorro'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :christmas_bonus do
          key :in, :query
          key :description, 'Aguinaldo'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :taxes do
          key :in, :query
          key :description, 'Impuestos'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :imms do
          key :in, :query
          key :description, 'Descuento del IMMS'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :savings_found do
          key :in, :query
          key :description, 'Fondo de ahorro'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :savings_found_loand do
          key :in, :query
          key :description, 'Prestamo de fondo de ahorro'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :savings_bank do
          key :in, :query
          key :description, 'Caja de ahorro'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :insurance_discount do
          key :in, :query
          key :description, 'Desuento de seguro'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :child_support do
          key :in, :query
          key :description, 'Pension alimenticia'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :extra_expenses do
          key :in, :query
          key :description, 'Descuento extraordinario'
          key :required, false
          key :type, :number
          key :format, :float
        end

        parameter name: :infonavit do
          key :in, :query
          key :description, 'Descuento de Infonavit'
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

        parameter name: :user_id do
          key :in, :query
          key :description, 'ID del usuario. FK USERS'
          key :required, true
          key :type, :string
          key :format, :uuid
        end

        parameter name: :file_type_id do
          key :in, :query
          key :description, 'ID del archivo del empleadp. FK FILE_TYPES'
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
