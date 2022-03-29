# == Schema Information
#
# Table name: customers
#
#  id             :uuid             not null, primary key
#  attached       :string
#  customer_type  :string           not null
#  extra1         :string
#  extra2         :string
#  extra3         :string
#  name           :string           not null
#  status         :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  contributor_id :uuid             not null
#  file_type_id   :uuid
#  user_id        :uuid             not null
#
# Indexes
#
#  index_customers_on_contributor_id  (contributor_id)
#  index_customers_on_file_type_id    (file_type_id)
#  index_customers_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (contributor_id => contributors.id)
#  fk_rails_...  (file_type_id => file_types.id)
#  fk_rails_...  (user_id => users.id)
#
class Customer < ApplicationRecord
  include Swagger::Blocks
  include Swagger::CustomerSchema  
  belongs_to :contributor
  belongs_to :user
  belongs_to :file_type
  has_many :project_requests
  has_many :projects
  has_many :customer_credits
  has_many :people, through: :contributors
  has_many :legal_entities, through: :contributors

  validates :customer_type, presence: true
  validates :name, presence: true
  validates :status, presence: true
end
