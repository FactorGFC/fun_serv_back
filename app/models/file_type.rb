# frozen_string_literal: true

# == Schema Information
#
# Table name: file_types
#
#  id            :uuid             not null, primary key
#  customer_type :string
#  description   :string           not null
#  extra1        :string
#  extra2        :string
#  extra3        :string
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class FileType < ApplicationRecord
  include Swagger::Blocks
  include Swagger::FileTypeSchema
  has_many :customers
  has_many :file_type_documents

  validates :description, presence: true
  validates :name, presence: true
end
