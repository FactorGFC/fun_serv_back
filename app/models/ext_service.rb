# == Schema Information
#
# Table name: ext_services
#
#  id         :uuid             not null, primary key
#  api_key    :string
#  extra1     :string
#  extra2     :string
#  extra3     :string
#  rule       :string
#  supplier   :string           not null
#  token      :string
#  url        :string           not null
#  user       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ExtService < ApplicationRecord
  include Swagger::Blocks
  include Swagger::ExtServiceSchema
  has_many :documents

  validates :supplier, presence: true
  validates :url, presence: true
  validates :user, presence: true
end
