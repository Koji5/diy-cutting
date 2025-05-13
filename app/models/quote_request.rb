class QuoteRequest < ApplicationRecord
  belongs_to :quote
  belongs_to :vendor, class_name: 'User', foreign_key: :vendor_id
end
