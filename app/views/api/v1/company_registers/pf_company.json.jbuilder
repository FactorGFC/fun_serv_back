# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @person,
                                 relations: ['contributors', 'contributor_addresses', 'companies', 'company_segments']