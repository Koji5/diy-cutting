class MEdgeProcess < ApplicationRecord
  self.primary_key = :code

  validates :code,    presence: true, length: { maximum: 10 }
  validates :name_ja, presence: true, length: { maximum: 20 }, uniqueness: true
  validates :name_en, presence: true, length: { maximum: 10 }, uniqueness: true
end
