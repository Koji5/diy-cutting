# db/migrate/XXXXXXXXXXXXXX_add_allow_paint_types_to_finishes_and_glosses.rb
class AddAllowPaintTypesToFinishesAndGlosses < ActiveRecord::Migration[8.0]
  def change
    # 本体カラム
    add_column :m_paint_finishes, :allow_paint_types, :jsonb, null: false, default: {}
    add_column :m_paint_glosses,  :allow_paint_types, :jsonb, null: false, default: {}

    # GINインデックス（JSON包含検索 @> などに有効）
    add_index :m_paint_finishes, :allow_paint_types, using: :gin
    add_index :m_paint_glosses,  :allow_paint_types, using: :gin
  end
end
