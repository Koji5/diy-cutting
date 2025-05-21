class VendorDetail < ApplicationRecord
  self.primary_key = :user_id

  # Associations
  belongs_to :user
  belongs_to :prefecture,
             class_name: 'MPrefecture',
             foreign_key: :office_prefecture_code,
             primary_key: :code
  belongs_to :city,
             class_name: 'MCity',
             foreign_key: :office_city_code,
             primary_key: :code
  # ★ 別名エイリアス
  belongs_to :office_city,
             class_name: 'MCity',
             foreign_key: :office_city_code,
             primary_key: :code,
             optional: true
  has_many :capabilities,
             class_name: 'VendorCapability',
             foreign_key: :vendor_id,
             inverse_of: :vendor_detail,
             dependent: :destroy
  has_many :service_prefectures,
             class_name: "VendorServicePrefecture",
             foreign_key: :vendor_id,
             dependent: :destroy
  has_many :service_areas,
             class_name: 'VendorServiceArea',
             foreign_key: :vendor_id,
             inverse_of: :vendor_detail,
             dependent: :destroy
  has_many :materials,
             class_name: 'VendorMaterial',
             foreign_key: :vendor_id,
             inverse_of: :vendor_detail,
             dependent: :destroy

  enum :account_type, { futsuu: 0, toza: 1 }
  enum :coverage_scope, { 
      all_japan: 0,
      prefectures: 1,
      cities: 2
    }

  # Validations
  validates :vendor_name, :office_prefecture_code,
            :office_city_code, :office_address_line, presence: true
  validates :invoice_number, uniqueness: true, allow_blank: true
  validates :contact_person_name, presence: true
end
