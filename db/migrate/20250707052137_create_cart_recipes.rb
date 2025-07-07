class CreateCartRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_recipes do |t|
      t.references :cart, null: false, foreign_key: true, index: true
      t.references :recipe, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
