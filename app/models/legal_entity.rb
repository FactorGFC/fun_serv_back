# == Schema Information
#
# Table name: legal_entities
#
#  id             :uuid             not null, primary key
#  business_email :string
#  business_name  :string           not null
#  email          :string
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  fiel           :boolean
#  fiscal_regime  :string           not null
#  main_activity  :string
#  mobile         :string
#  phone          :string
#  rfc            :string           not null
#  rug            :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class LegalEntity < ApplicationRecord
  include Swagger::Blocks
  include Swagger::LegalEntitySchema
  has_many :contributors
  has_many :contributor_addresses, through: :contributors
  has_many :customers, through: :contributors
  has_many :funders, through: :contributors
  #before_save :get_authorization_key

  validates :fiscal_regime, presence: true
  validates :rfc, presence: true, uniqueness: true
  validates :business_name, presence: true

  #def get_authorization_key
  #  unless self[:extra2].blank?
  #    authorization = Base64.encode64("#{self[:rfc]}:#{self[:extra2]}")      
  #    self[:extra3] = "Basic #{authorization.chomp}" #chomp elimina los \n de final de un string
  #  end
  #end
end
