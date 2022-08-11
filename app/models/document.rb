# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id             :uuid             not null, primary key
#  description    :string           not null
#  document_type  :string           not null
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  name           :string           not null
#  validation     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  ext_service_id :uuid
#
# Indexes
#
#  index_documents_on_ext_service_id  (ext_service_id)
#
# Foreign Keys
#
#  fk_rails_...  (ext_service_id => ext_services.id)
#

class Document < ApplicationRecord
  include Swagger::Blocks
  include Swagger::DocumentSchema  
  belongs_to :ext_service, optional: true
  has_many :file_type_documents

  validates :document_type, presence: true
  validates :name, presence: true
  validates :description, presence: true 

end