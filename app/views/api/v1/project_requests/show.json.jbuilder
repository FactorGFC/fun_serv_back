# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @project_request,
                                 relations: ['customer_credits']