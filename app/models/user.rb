# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :uuid             not null, primary key
#  company_signatory    :string
#  email                :string           default(""), not null
#  gender               :string
#  job                  :string
#  name                 :string           default(""), not null
#  password_digest      :string           default(""), not null
#  reset_password_token :string
#  status               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  company_id           :uuid
#  role_id              :uuid
#
# Indexes
#
#  index_users_on_company_id  (company_id)
#  index_users_on_role_id     (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (role_id => roles.id)
#
class User < ApplicationRecord
  include Swagger::Blocks
  include Swagger::UserSchema
  include Swagger::ApiSessionSchema
 has_many :tokens, dependent: :destroy
  has_many :my_polls
  has_many :my_apps, dependent: :destroy
  has_many :user_polls
  belongs_to :roles, optional: true
  belongs_to :company, optional: true
  has_many :user_options, dependent: :destroy
  has_many :options, through: :user_options
  has_many :user_privileges
  has_many :customers
  has_many :customer_credits
  validates :email, presence: true, email: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :name, presence: true
  validates :company_signatory, presence: false
  #ver que hace esto
  has_secure_password

  def self.from_omniauth(data)
    @user = User.find_by(email: data[:email])
    @user if @user && authenticate(data[:password])
  end

  private

  def self.authenticate(password)
    BCrypt::Password.new(@user.password_digest) == password
  end

end
