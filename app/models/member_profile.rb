class MemberProfile < ApplicationRecord
  belongs_to :account
  validates :billing_name, presence: true
  validates :billing_name_kana, length: { maximum: 100 }, allow_blank: true
end