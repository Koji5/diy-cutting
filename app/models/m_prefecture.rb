class MPrefecture < ApplicationRecord
  self.primary_key = :code

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  validates :code,    presence: true, length: { is: 2 }
  validates :name_ja, presence: true, length: { maximum: 10 }, uniqueness: true
  validates :name_en, presence: true, length: { maximum: 20 }
  validates :kana,    presence: true, length: { maximum: 20 }
end