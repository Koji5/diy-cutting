class MPostalCode < ApplicationRecord
  self.table_name = "m_postal_codes"   # 明示しておくと安心

  # 参照先
  belongs_to :city,
             class_name:  "MCity",
             foreign_key: :city_code,
             primary_key: :code,
             optional: true  # FK が必ずあるなら false でも OK
end
