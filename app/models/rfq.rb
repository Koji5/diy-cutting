class Rfq < ApplicationRecord

  belongs_to :shipping_address, class_name: "MemberShippingAddress", optional: true

end