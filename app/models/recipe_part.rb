class RecipePart < ApplicationRecord
  belongs_to :recipe
  belongs_to :part

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }

  # DB で UNIQUE が無いのでアプリ側で重複を防ぐ（必要なら add_index で追加）
  validates :part_id,
            uniqueness: { scope: :recipe_id,
                          message: "はレシピ内で重複できません" }
end
