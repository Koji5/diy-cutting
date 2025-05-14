class AffiliateSignup < ApplicationRecord
  belongs_to :affiliate_user,
             class_name: 'User',
             foreign_key: :affiliate_user_id

  belongs_to :affiliate_click,
             class_name: 'HAffiliateClick',
             foreign_key: :affiliate_click_id,
             optional: true

  belongs_to :signup_user,
             class_name: 'User',
             foreign_key: :signup_user_id

  # バリデーション
  validates :signup_user_id, uniqueness: true
end
