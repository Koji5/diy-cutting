class AddQuantityToCartRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :cart_recipes, :quantity, :integer, null: false, default: 1
  end
end
