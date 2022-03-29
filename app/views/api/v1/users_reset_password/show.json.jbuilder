# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @user,
                                 relations: ['user_options', 'options']

json.call(@reset_password_token, :token, :expires_at)