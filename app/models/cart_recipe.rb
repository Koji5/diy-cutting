class CartRecipe < ApplicationRecord
  belongs_to :cart
  belongs_to :recipe
end
