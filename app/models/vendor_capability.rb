class VendorCapability < ApplicationRecord
  self.primary_keys = :vendor_id, :capability_code   # composite_key gem不要で使える記法

  belongs_to :vendor_detail,
             class_name:  'VendorDetail',
             foreign_key: :vendor_id,
             primary_key: :user_id,
             inverse_of:  :capabilities

  belongs_to :process_type,
             class_name:  'MProcessType',
             foreign_key: :capability_code,
             primary_key: :code,
             inverse_of:  :vendor_capabilities
end
