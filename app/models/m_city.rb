class MCity < ApplicationRecord
  self.primary_key = :code

  # ─── 関連 ───
  belongs_to :prefecture,
             class_name:  "MPrefecture",
             foreign_key: "prefecture_code",
             primary_key: "code"

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :deleted_by, class_name: "User", optional: true

  # ─── バリデーション ───
  validates :code,            presence: true, length: { is: 5 }
  validates :prefecture_code, presence: true, length: { is: 2 }
  validates :name_ja,         presence: true, length: { maximum: 100 }
end