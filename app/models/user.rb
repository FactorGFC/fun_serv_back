# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :uuid             not null, primary key
#  email                :string           default(""), not null
#  gender               :string
#  job                  :string
#  name                 :string           default(""), not null
#  password_digest      :string           default(""), not null
#  reset_password_token :string
#  status               :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  role_id              :uuid
#
# Indexes
#
#  index_users_on_role_id  (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#

class User < ApplicationRecord
  include Swagger::Blocks
  include Swagger::UserSchema
  include Swagger::ApiSessionSchema
  validates :email, presence: true, email: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :name, presence: true
  has_many :tokens, dependent: :destroy
  has_many :my_polls
  has_many :my_apps, dependent: :destroy
  has_many :user_polls
  belongs_to :roles, optional: true
  has_many :user_options, dependent: :destroy
  has_many :options, through: :user_options
  has_many :user_privileges
  has_many :customers
  has_many :funders
  has_many :project_requests
  has_many :projects
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
