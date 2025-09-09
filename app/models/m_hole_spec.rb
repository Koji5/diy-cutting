class MHoleSpec < ApplicationRecord
  self.primary_key = :code

  CATEGORIES = %w[BOLT_METRIC DOWEL].freeze

  validates :code, :name_ja, :name_en, :category_code, presence: true
  validates :category_code, inclusion: { in: CATEGORIES }
  validates :nominal_mm, :pilot_mm, :min_center_center_mm, :min_edge_distance_mm,
            numericality: { greater_than: 0 }
  validates :countersink_mm, numericality: { greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(:sort_order, :code) }
end
