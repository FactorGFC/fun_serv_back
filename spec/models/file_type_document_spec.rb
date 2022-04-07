# frozen_string_literal: true
# == Schema Information
#
# Table name: file_type_documents
#
#  id           :uuid             not null, primary key
#  extra1       :string
#  extra2       :string
#  extra3       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  document_id  :uuid             not null
#  file_type_id :uuid             not null
#
# Indexes
#
#  index_file_type_documents_on_document_id   (document_id)
#  index_file_type_documents_on_file_type_id  (file_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#  fk_rails_...  (file_type_id => file_types.id)
#
require 'rails_helper'

RSpec.describe FileTypeDocument, type: :model do
  it { should belong_to(:document) }
  it { should belong_to(:file_type) }
end
