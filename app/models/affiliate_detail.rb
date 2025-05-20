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

  enum :account_type, { futsuu: 0, toza: 1 }   # 普通／当座

  # 役割整合チェック（アプリ層）
  validates :user,   presence: true
  validates :name, :postal_code, :prefecture_code,
            :city_code, :address_line, presence: true
  validates :commission_rate, numericality: { greater_than: 0 }
end
