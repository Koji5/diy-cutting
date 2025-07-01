class AddDiscardedAtToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :deleted_flag, :boolean, default: false, null: false
    add_column :recipes, :deleted_at,   :datetime, precision: 6

    add_reference :recipes, :deleted_by, foreign_key: { to_table: :users }, type: :bigint
    add_reference :recipes, :created_by, foreign_key: { to_table: :users }, type: :bigint
    add_reference :recipes, :updated_by, foreign_key: { to_table: :users }, type: :bigint

    # よく使うなら `deleted_flag` にインデックスを張っておくと高速
    add_index :recipes, :deleted_flag
  end
end
