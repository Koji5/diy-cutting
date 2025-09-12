class AddSortOrderToMMaterials < ActiveRecord::Migration[8.0]
  def up
    # まずNULL許容で追加（テーブル再書き換えやロックを軽めにするため段階的に）
    add_column :m_materials, :sort_order, :integer

    # 既存行を0で埋める
    execute <<~SQL
      UPDATE public.m_materials
         SET sort_order = 0
       WHERE sort_order IS NULL
    SQL

    # 以後の新規行は0をデフォルトに
    change_column_default :m_materials, :sort_order, from: nil, to: 0
    # NOT NULL 制約を付与
    change_column_null :m_materials, :sort_order, false

    # カテゴリ内での並びを想定した複合インデックス
    add_index :m_materials, [:category_code, :sort_order], name: :index_m_materials_on_category_sort
  end

  def down
    remove_index :m_materials, name: :index_m_materials_on_category_sort
    remove_column :m_materials, :sort_order
  end
end
