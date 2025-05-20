class VendorServicePrefecture < ApplicationRecord
  belongs_to :vendor_detail, foreign_key: :vendor_id
  belongs_to :prefecture, class_name: "MPrefecture", foreign_key: :prefecture_code

  validates :prefecture_code, uniqueness: { scope: :vendor_id }
end