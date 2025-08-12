class MGloss < ApplicationRecord
  self.primary_key = :code

  validates :code,    presence: true, length: { maximum: 6 }
  validates :name_ja, :name_en, presence: true, length: { maximum: 30 }, uniqueness: true
  validates :gloss_pct,
            presence: true,
            numericality: { greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100,
                            only_integer: true }
end
