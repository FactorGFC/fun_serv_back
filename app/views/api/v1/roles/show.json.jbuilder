# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @role,
                                 relations: ['role_options', 'options']
