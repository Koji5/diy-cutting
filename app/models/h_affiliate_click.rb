class HAffiliateClick < ApplicationRecord
  self.table_name = 'h_affiliate_clicks'

  belongs_to :affiliate_user, class_name: 'User'

  validates :click_token, presence: true, uniqueness: true
end
