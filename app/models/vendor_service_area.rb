class VendorServiceArea < ApplicationRecord
  self.primary_keys = :vendor_id, :prefecture_code, :city_code   # Rails 8 複合 PK

  belongs_to :vendor_detail,
             class_name:  'VendorDetail',
             foreign_key: :vendor_id,
             primary_key: :user_id,
             inverse_of:  :service_areas

  belongs_to :prefecture,
             class_name:  'MPrefecture',
             foreign_key: :prefecture_code,
             primary_key: :code

  belongs_to :city,
             class_name:  'MCity',
             foreign_key: :city_code,
             primary_key: :code
end