class Recipe < ApplicationRecord
  ## 関連
  belongs_to :account
  has_many   :recipe_parts,  dependent: :destroy
  has_many   :parts,         through: :recipe_parts
  has_many   :cart_recipes,  dependent: :destroy
  has_many   :carts,         through: :cart_recipes
  has_one_attached :thumbnail

  # Snapshot モデルがある場合
  belongs_to :latest_snapshot,
             class_name: "RecipeSnapshot",
             optional: true

  belongs_to :origin_owner,
             class_name:  'User',
             foreign_key: :origin_owner_id,
             optional:    true

  ## enum - ユーザーが好むシンボル第一引数形式
  enum :status, { draft: 0, published: 1, archived: 2 }

  ## バリデーション
  validates :name, presence: true, length: { maximum: 60 }
  validates :thumbnail,
            content_type: { in: %w[image/png image/jpeg image/webp],
                            message: 'は PNG / JPG / WEBP にしてください' },
            size:         { less_than: 5.megabytes,
                            message: 'は 5 MB 以内にしてください' }

  private
end
