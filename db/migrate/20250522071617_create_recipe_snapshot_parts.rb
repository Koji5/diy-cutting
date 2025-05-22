class CreateRecipeSnapshotParts < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_snapshot_parts do |t|
      t.references :recipe_snapshot,   null: false, foreign_key: true
      t.references :part_snapshot,     null: false, foreign_key: true
      t.integer    :quantity,          null: false
      t.timestamps
    end
  end
end