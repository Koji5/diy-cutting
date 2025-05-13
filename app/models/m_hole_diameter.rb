class MHoleDiameter < ApplicationRecord
  self.primary_key = :code

  validates :code,    presence: true, length: { maximum: 10 }
  validates :hole_mm, presence: true, numericality: { greater_than: 0 }
  validates :name_ja, :name_en, presence: true, uniqueness: true
end
