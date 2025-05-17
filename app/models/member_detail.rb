class MemberDetail < ApplicationRecord
  enum :role, { member: 4 }
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
end