class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_parts,   dependent: :destroy
  has_many :parts,      through: :cart_parts
  has_many :cart_recipes, dependent: :destroy
  has_many :recipes,      through: :cart_recipes

  ## enum - ユーザーが好むシンボル第一引数形式
  enum :status, { draft: 0, published: 1, archived: 2 }
  validates :name, presence: true, length: { maximum: 60 }
end
