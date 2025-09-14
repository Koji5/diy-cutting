class AddSortOrderToPaintFinish < ActiveRecord::Migration[8.0]
  def up
    %i[m_paint_finishes].each do |table|
      # カラム追加（最初はNULL許容）
      add_column table, :sort_order, :integer

      # 既存データを0で埋める
      execute <<~SQL
        UPDATE #{table}
           SET sort_order = 0
         WHERE sort_order IS NULL
      SQL

      # デフォルトとNOT NULLを付与
      change_column_default table, :sort_order, from: nil, to: 0
      change_column_null table, :sort_order, false

      # 単純なソート用途なら単一インデックスで十分
      add_index table, :sort_order
    end
  end

  def down
    %i[m_paint_finishes].each do |table|
      remove_index table, :sort_order
      remove_column table, :sort_order
    end
  end
end
