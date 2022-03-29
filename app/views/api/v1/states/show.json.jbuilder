# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @state,
                                 relations: ['municipalities']
