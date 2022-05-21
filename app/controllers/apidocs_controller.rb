class ApidocsController < ApplicationController
    include Swagger::Blocks
  
    swagger_root do
      key :swagger, '2.0'
      info do
        key :version, '1.0.0'
        key :title, 'Credit_request_backend API'
        key :description, 'Backend para sistema de solicitud de nomina'
        contact do
          key :name, 'Griselda Oaxaca'
          key :email, 'griselda010@gmail.com'
        end
      end
      tag do
        key :name, 'User'
        key :description, 'Operaciones con usuarios | SP: user | Relations: UserOptions'
      end
      tag do
        key :name, 'Authentication'
        key :description, 'Crea una sesión del usuario'
      end
      tag do
        key :name, 'Role'
        key :description, 'Operaciones con roles  | SP: role | Relations: RoleOptions'
      end
      tag do
        key :name, 'Option'
        key :description, 'Operaciones con opciones | SP: option'
      end
      tag do
        key :name, 'RoleOption'
        key :description, 'Operaciones para asociar una opción a un rol'
      end
      tag do
        key :name, 'UserOption'
        key :description, 'Operaciones para asociar una opción a un usuario'
      end
      tag do
        key :name, 'UserPrivilege'
        key :description, 'Operaciones para privilegios de usuario | SP: user_privilege'
      end
      tag do
        key :name, 'List'
        key :description, 'Operaciones para listas valores | SP: list'
      end
      tag do
        key :name, 'GeneralParameter'
        key :description, 'Operaciones para parámetros generales | SP: general_parameter'
      end
      tag do
        key :name, 'Person'
        key :description, 'Operaciones para personas físicas | SP: person'
      end
      tag do
        key :name, 'LegalEntity'
        key :description, 'Operaciones para personas morales | SP: legal_entity'
      end
      tag do
        key :name, 'Contributor'
        key :description, 'Operaciones para contribuyentes | SP: contributor'
      end
      tag do
        key :name, 'Country'
        key :description, 'Operaciones para países | Relations: States'
      end
      tag do
        key :name, 'State'
        key :description, 'Operaciones para estados | Relations: Cities'
      end
      #tag do
      #  key :name, 'City'
      #  key :description, 'Operaciones para ciudades | SP: city'
      #end
      tag do
        key :name, 'Municipality'
        key :description, 'Operaciones para municipios | SP: municipality'
      end
      tag do
        key :name, 'PostalCode'
        key :description, 'Consulta de colonias por código postal'
      end
      tag do
        key :name, 'ContributorAddress'
        key :description, 'Operaciones para domicilios | SP: contributor_address'
      end
      tag do
        key :name, 'Report'
        key :description, 'Reportes | 1 UserNotOptions, 2 RoleNotOptions'
      end
      tag do
        key :name, 'Customer'
        key :description, 'Operaciones para clientes | SP: customers'
      end
      tag do
        key :name, 'CustomerPersonalReference'
        key :description, 'Referencias personales del empleado | SP: customer_personal_references'
      end
      tag do
        key :name, 'ExtService'
        key :description, 'Operaciones para servicios externos | SP: ext_service'
      end
      tag do
        key :name, 'FileType'
        key :description, 'Operaciones tipos de expediente | SP: file_type'
      end
      tag do
        key :name, 'FileTypeDocument'
        key :description, 'Operaciones para asociar tipos de expedientes con documentos | SP: file_type_document'
      end
      tag do
        key :name, 'Document'
        key :description, 'Operaciones para documentos | SP: document'
      end
      tag do
        key :name, 'ContributorDocument'
        key :description, 'Operaciones para asociar a un contribuyente con los documentos de su expediente | SP: contributor_document'
      end
      tag do
        key :name, 'Term'
        key :description, 'Operaciones para Plazos | SP: term'
      end
      tag do
        key :name, 'PaymentPeriod'
        key :description, 'Operaciones Periodos de pago | SP: payment_period'
      end
      tag do
        key :name, 'CreditRating'
        key :description, 'Operaciones para calificación de créditos | SP: credit_rating'
      end
      tag do
        key :name, 'Rate'
        key :description, 'Operaciones tasas | SP: rate'
      end
      tag do
        key :name, 'Company'
        key :description, 'Operaciones con solicitudes de proyecto | SP: company'
      end
      tag do
        key :name, 'CustomerCredit'
        key :description, 'Operaciones con creditos | SP: customer_credit'
      end
      tag do
        key :name, 'SimCustomerPayment'
        key :description, 'Operaciones pagos a créditos| SP: sim_custoemer_payment'
      end
      tag do
        key :name, 'ExtRate'
        key :description, 'Operaciones para tasas externas| SP: ext_rate'
      end
      tag do
        key :name, 'CreditAnalysis'
        key :description, 'Operaciones para el analisis de la solicitud de credito| SP: credit_analysis'
      end
      key :basePath, '/'
      key :schemes, ['http']
      key :consumes, ['application/json']
      key :produces, ['application/json']
    end
  
    # A list of all classes that have swagger_* declarations.
    SWAGGERED_CLASSES = [
      Api::V1::UsersController,
      User,
      Api::V1::RolesController,
      Role,
      Api::V1::OptionsController,
      Option,
      Api::V1::RoleOptionsController,
      RoleOption,
      Api::V1::UserOptionsController,
      UserOption,
      Api::V1::ApiSessionsController,
      Api::V1::UserPrivilegesController,
      UserPrivilege,
      Api::V1::ListsController,
      List,
      Api::V1::GeneralParametersController,
      GeneralParameter,
      Api::V1::PeopleController,
      Person,
      Api::V1::LegalEntitiesController,
      LegalEntity,
      Api::V1::ContributorsController,
      Contributor,    
      Api::V1::CountriesController,
      Country,
      Api::V1::StatesController,
      State,
      #Api::V1::CitiesController,
      #City,
      Api::V1::MunicipalitiesController,
      Municipality,
      Api::V1::PostalCodesController,
      PostalCode,
      Api::V1::ContributorAddressesController,
      ContributorAddress,
      Api::V1::ReportsController,
      Api::V1::CustomersController,
      Customer,
      Api::V1::CustomerPersonalReferencesController,
      CustomerPersonalReference,
      Api::V1::ExtServicesController,
      ExtService,
      Api::V1::FileTypesController,
      FileType,
      Api::V1::FileTypeDocumentsController,
      FileTypeDocument,
      Api::V1::DocumentsController,
      Document,
      Api::V1::ContributorDocumentsController,
      ContributorDocument,
      Api::V1::TermsController,
      Term,
      Api::V1::PaymentPeriodsController,
      PaymentPeriod,
      Api::V1::CreditRatingsController,
      CreditRating,
      Api::V1::RatesController,
      Rate,
      Api::V1::CompaniesController,
      Company,
      Api::V1::CustomerCreditsController,
      CustomerCredit,
      Api::V1::SimCustomerPaymentsController,
      SimCustomerPayment,
      Api::V1::ExtRatesController,
      ExtRate,
      self
    ].freeze
  
    def index
      render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
    end
end
  