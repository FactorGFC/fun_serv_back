# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @customer_personal_reference,
                                 relations: ['customer']