class ChangeShapeColumnsToJsonb < ActiveRecord::Migration[8.0]
  # 既存データは不要という前提で、旧 text[] カラムを drop → jsonb で再作成
  def change
    change_table :m_shapes do |t|
      # ---- 旧カラムを削除 -------------------------------------------------
      t.remove :allow_shape_json,  :allow_corner_json, :allow_edge_json

      # ---- 新しい JSONB カラムを追加 --------------------------------------
      t.jsonb :allow_shape_json,  default: {}, null: false
      t.jsonb :allow_corner_json, default: {}, null: false
      t.jsonb :allow_edge_json,   default: {}, null: false
    end
  end
end
