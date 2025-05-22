# db/migrate/XXXXXXXXXX_finalize_snapshot_refs_and_quantity.rb
class FinalizeSnapshotRefsAndQuantity < ActiveRecord::Migration[8.0]
  def change
    # -------------------------------
    # recipe_snapshot_parts
    # -------------------------------
    change_table :recipe_snapshot_parts, bulk: true do |t|
      # ① part_snapshot_id が無い場合は追加
      unless column_exists?(:recipe_snapshot_parts, :part_snapshot_id)
        t.references :part_snapshot, null: false, foreign_key: true
      end

      # ② quantity カラムを NOT NULL & デフォルト 1
      if column_exists?(:recipe_snapshot_parts, :quantity)
        change_column_null :recipe_snapshot_parts, :quantity, false, 1
        change_column_default :recipe_snapshot_parts, :quantity, 1
      else
        t.integer :quantity, null: false, default: 1
      end

      # ③ インデックス
      t.index :part_snapshot_id unless index_exists?(:recipe_snapshot_parts, :part_snapshot_id)
    end

    # -------------------------------
    # rfq_parts
    # -------------------------------
    change_table :rfq_parts, bulk: true do |t|
      unless column_exists?(:rfq_parts, :part_snapshot_id)
        t.references :part_snapshot, null: false, foreign_key: true
      end

      if column_exists?(:rfq_parts, :quantity)
        change_column_null :rfq_parts, :quantity, false, 1
        change_column_default :rfq_parts, :quantity, 1
      else
        t.integer :quantity, null: false, default: 1
      end

      t.index :part_snapshot_id unless index_exists?(:rfq_parts, :part_snapshot_id)
    end
  end
end
