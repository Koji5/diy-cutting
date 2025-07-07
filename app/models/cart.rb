class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_parts,   dependent: :destroy
  has_many :parts,      through: :cart_parts
  has_many :cart_recipes, dependent: :destroy
  has_many :recipes,      through: :cart_recipes
end
