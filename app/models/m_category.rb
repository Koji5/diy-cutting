# app/models/m_category.rb
class MCategory < ApplicationRecord
  self.primary_key = :code

  has_many :materials,
           class_name:  'MMaterial',
           foreign_key: :category_code,
           inverse_of:  :category

  has_many :process_types,
           class_name:  'MProcessType',
           foreign_key: :category_code,
           inverse_of:  :category

  has_many :quote_items,
           class_name:  'QuoteItem',
           foreign_key: :material_category_code,
           inverse_of:  :category

  # --- Validations ---
  validates :code,    presence: true, length: { maximum: 10 }
  validates :name_ja, presence: true, length: { maximum: 20 }, uniqueness: true
  validates :name_en, presence: true, length: { maximum: 20 }, uniqueness: true
end
