# frozen_string_literal: true

# == Schema Information
#
# Table name: tokens
#
#  id         :uuid             not null, primary key
#  expires_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  my_app_id  :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_tokens_on_my_app_id  (my_app_id)
#  index_tokens_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (my_app_id => my_apps.id)
#  fk_rails_...  (user_id => users.id)
#

class Token < ApplicationRecord
  belongs_to :user
  belongs_to :my_app
  before_create :generate_token
  def is_valid?
    DateTime.now < expires_at
  end

  private

  def generate_token
    begin
      self.token = SecureRandom.hex
      # puts "\n#{"bbbb"}\n #{self.token.inspect} \n#{"bbbb"}\n"
    end while Token.where(token: token).any?
    self.expires_at ||= 1.day.from_now
  end
end
