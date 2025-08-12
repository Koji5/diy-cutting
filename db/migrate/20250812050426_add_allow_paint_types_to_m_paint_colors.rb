# db/migrate/XXXXXXXXXXXXXX_add_allow_paint_types_to_m_paint_colors.rb
class AddAllowPaintTypesToMPaintColors < ActiveRecord::Migration[8.0]
  def change
    # JSONB 本体（空オブジェクトを既定、NULL不可）
    add_column :m_paint_colors, :allow_paint_types, :jsonb, null: false, default: {}

    # JSON 包含検索用の GIN インデックス
    add_index  :m_paint_colors, :allow_paint_types, using: :gin
  end
end
