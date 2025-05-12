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
  belongs_to :stripe_account,
             class_name: 'StripeAccount',
             foreign_key: :stripe_account_id,
             primary_key: :stripe_account_id

  has_many :capabilities,
             class_name: 'VendorCapability',
             foreign_key: :vendor_id,
             inverse_of: :vendor_detail,
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
    
  # Validations
  validates :vendor_name, presence: true, length: { maximum: 100 }
  validates :invoice_number, length: { maximum: 20 }, allow_blank: true,
            uniqueness: true
  validates :office_address_line, presence: true, length: { maximum: 200 }
  validates :stripe_account_id, presence: true
  validates :charges_enabled, :payouts_enabled,
            inclusion: { in: [true, false] }
end
