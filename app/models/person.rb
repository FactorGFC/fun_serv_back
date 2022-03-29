# == Schema Information
#
# Table name: people
#
#  id               :uuid             not null, primary key
#  birth_country    :string
#  birthdate        :date             not null
#  birthplace       :string
#  curp             :string
#  email            :string
#  extra1           :string
#  extra2           :string
#  extra3           :string
#  fiel             :boolean
#  first_name       :string           not null
#  fiscal_regime    :string           not null
#  gender           :string
#  id_type          :string
#  identification   :bigint           not null
#  imss             :bigint
#  last_name        :string           not null
#  martial_status   :string
#  mobile           :string
#  nationality      :string
#  phone            :string
#  rfc              :string           not null
#  second_last_name :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Person < ApplicationRecord
  include Swagger::Blocks
  include Swagger::PersonSchema
  has_many :contributors
  #before_save :get_authorization_key
  has_many :contributor_addresses, through: :contributors
  has_many :customers, through: :contributors
  has_many :funders, through: :contributors

  validates :fiscal_regime, presence: true
  validates :rfc, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :second_last_name, presence: true
  validates :birthdate, presence: true
  validates :identification, presence: true

  #def get_authorization_key
  #  unless self[:extra2].blank?
  #    authorization = Base64.encode64("#{self[:rfc].to_s}:#{self[:extra2].to_s}")
  #    self[:extra3] = "Basic #{authorization.chomp}" #chomp elimina los \n de final de un string
  #  end
  #end
end
