class Order < ApplicationRecord
  belongs_to :user          # 会員
  belongs_to :vendor,    class_name: 'User'
  belongs_to :affiliate, class_name: 'User', optional: true
  belongs_to :shipping_address,
             class_name: 'TransactionShippingAddress'

  enum status: {
    pending: 0, paid: 1, in_production: 2,
    shipped: 3, delivered: 4, cancelled: 5
  }, _prefix: true

  enum shipping_method: {
    yamato_b2: 0, vendor_direct: 1
  }, _prefix: true
end
