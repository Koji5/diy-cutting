class MemberDetail < ApplicationRecord
  enum :role, { member: 4 }
  self.primary_key = :user_id
  has_one :user,
          as:         :detail,      # ポリモーフィックキー (detail_type / detail_id)
          inverse_of: :detail,      # ← キャッシュ効率が上がる程度、あってもなくても動く
          dependent:  :destroy      # ユーザー削除時に道連れにするなら付ける
  has_many :shipping_addresses,
           class_name: "MemberShippingAddress",
           foreign_key: :member_id,
           dependent: :destroy
  belongs_to :primary_shipping_address,
             class_name: "MemberShippingAddress",
             foreign_key: :primary_shipping_id,
             optional: true
end