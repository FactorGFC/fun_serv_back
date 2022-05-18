# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @payment,
                                 relations: ['payment_credits']
