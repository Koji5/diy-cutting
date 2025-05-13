class Quote < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address,
             class_name: 'MemberShippingAddress',
             foreign_key: :shipping_address_id
  has_many   :quote_requests, dependent: :destroy
  belongs_to :accepted_request,
             class_name: 'QuoteRequest',
             optional: true
end