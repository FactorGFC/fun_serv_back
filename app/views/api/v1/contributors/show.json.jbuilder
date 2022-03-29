# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @contributor,
                                  relations: ['contributor_documents']
