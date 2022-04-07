# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @user,
                                 relations: ['customers']