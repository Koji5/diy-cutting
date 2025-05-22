class CreateRecipeSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :recipe_snapshots do |t|
      t.references :recipe,  null: false, foreign_key: true
      t.integer    :version, null: false
      t.datetime   :published_at
      t.timestamps
    end
  end
end