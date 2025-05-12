class AdminDetail < ApplicationRecord
  self.primary_key = :user_id

  belongs_to :user

  validates :nickname, length: { maximum: 50 }, uniqueness: true, allow_blank: true
  validates :icon_url, length: { maximum: 255 }, allow_blank: true
  validates :department, length: { maximum: 100 }, allow_blank: true
end
