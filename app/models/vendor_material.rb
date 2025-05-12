class VendorMaterial < ApplicationRecord
  self.primary_keys = :vendor_id, :material_code   # Rails 8 – 複合 PK

  belongs_to :vendor_detail,
             class_name:  'VendorDetail',
             foreign_key: :vendor_id,
             primary_key: :user_id,
             inverse_of:  :materials

  belongs_to :material,
             class_name:  'MMaterial',
             foreign_key: :material_code,
             primary_key: :code,
             inverse_of:  :vendor_materials
end
