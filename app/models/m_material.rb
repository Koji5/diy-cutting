class MMaterial < ApplicationRecord
  self.primary_key = :code

  belongs_to :category,
             class_name: 'MCategory',
             foreign_key: :category_code,
             primary_key: :code,
             inverse_of:  :materials

  validates :code,        presence: true, length: { maximum: 16 }
  validates :name_ja, :name_en, presence: true, length: { maximum: 40 },
                                uniqueness: true
  validates :density_kg_per_m3,
            numericality: { greater_than: 0 }
end
