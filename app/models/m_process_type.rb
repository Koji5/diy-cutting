class MProcessType < ApplicationRecord
  self.primary_key = :code

  belongs_to :category,
             class_name: 'MCategory',
             foreign_key: :category_code,
             primary_key: :code,
             inverse_of:  :process_types

  has_many :vendor_capabilities,
             class_name: 'VendorCapability',
             foreign_key: :capability_code,
             inverse_of: :process_type

  validates :code, presence: true, length: { maximum: 10 }
  validates :name_ja, :name_en, presence: true, length: { maximum: 40 },
                                uniqueness: true
end
