class AffiliateDetail < ApplicationRecord
  self.primary_key = :user_id

  belongs_to :user
  belongs_to :prefecture,
             class_name: 'MPrefecture',
             foreign_key: :prefecture_code,
             primary_key: :code
  belongs_to :city,
             class_name: 'MCity',
             foreign_key: :city_code,
             primary_key: :code
  belongs_to :stripe_account,
             class_name: 'StripeAccount',
             foreign_key: :stripe_account_id,
             primary_key: :stripe_account_id

  # 役割整合チェック（アプリ層）
  validates :user,   presence: true
  validates :name,   presence: true, length: { maximum: 100 }
  validates :commission_rate, numericality: { greater_than: 0 }
end
