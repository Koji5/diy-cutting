class CreateRecipeParts < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_parts do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :part,   null: false, foreign_key: true
      t.integer    :quantity, null: false, default: 1
      t.timestamps
    end
  end
end
