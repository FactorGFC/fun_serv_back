# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @project,
                                relations: ['customer_credits']