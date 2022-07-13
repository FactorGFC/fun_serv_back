# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @legal_entity,
                                 relations: ['contributors', 'contributor_addresses', 'companies']