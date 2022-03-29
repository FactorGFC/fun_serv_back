# frozen_string_literal: true

# == Schema Information
#
# Table name: my_apps
#
#  id                 :uuid             not null, primary key
#  javascript_origins :string
#  secret_key         :string
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  app_id             :string
#  user_id            :uuid             not null
#
# Indexes
#
#  index_my_apps_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class MyApp < ApplicationRecord
  belongs_to :user
  has_many :tokens
  validates :title, presence: true
  validates :user, presence: true
  validates :secret_key, uniqueness: true
  validates :app_id, uniqueness: true

  before_create :generate_app_id
  before_create :generate_secret_key

  def is_your_token?(token)
    tokens.where(tokens: { id: token.id }).any?
  end

  def is_valid_origin(domain)
    javascript_origins.split(',').include?(domain)
  end

  private

  def generate_secret_key
    begin
      self.secret_key = SecureRandom.hex
    end while MyApp.where(secret_key: secret_key).any?
  end

  def generate_app_id
    begin
      self.app_id = SecureRandom.hex
    end while MyApp.where(secret_key: app_id).any?
  end
end
