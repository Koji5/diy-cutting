class MHoleSurface < ApplicationRecord
  self.primary_key = :code
  validates :code, presence: true
  validates :name_ja, :name_en, presence: true
  scope :ordered, -> { order(:sort_order, :code) }
end
