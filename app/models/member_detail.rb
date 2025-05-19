class MemberDetail < ApplicationRecord
  enum :membership_plan, { free: 0 }
  self.primary_key = :user_id
  belongs_to :user, inverse_of: :member_detail
  has_many :shipping_addresses,
           class_name: "MemberShippingAddress",
           foreign_key: :member_id,
           dependent: :destroy
  belongs_to :primary_shipping_address,
           class_name: "MemberShippingAddress",
           foreign_key: :primary_shipping_id,
           optional: true
  belongs_to :registered_affiliate,
           class_name: "User",
           optional: true
end