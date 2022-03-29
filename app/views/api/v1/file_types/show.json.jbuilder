# frozen_string_literal: true

json.partial! 'api/v1/resource', resource: @file_type,
                                 relations: ['file_type_documents', 'documents']