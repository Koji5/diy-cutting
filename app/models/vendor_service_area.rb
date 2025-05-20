class VendorServiceArea < ApplicationRecord

  belongs_to :vendor_detail,
             class_name:  'VendorDetail',
             foreign_key: :vendor_id,
             inverse_of:  :service_areas

  belongs_to :prefecture,
             class_name:  'MPrefecture',
             foreign_key: :prefecture_code

  belongs_to :city,
             class_name:  'MCity',
             foreign_key: :city_code

  validates :city_code, uniqueness: { scope: :vendor_id }

  delegate :prefecture, to: :city
end