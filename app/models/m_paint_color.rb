class MPaintColor < ApplicationRecord
  self.primary_key = :code

  validates :code,    presence: true, length: { maximum: 6 }
  validates :name_ja, :name_en, presence: true, length: { maximum: 30 }, uniqueness: true
end
