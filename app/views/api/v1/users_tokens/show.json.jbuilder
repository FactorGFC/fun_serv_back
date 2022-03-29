# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @user,
                                 relations: ['user_options']

json.call(@token, :token, :expires_at)