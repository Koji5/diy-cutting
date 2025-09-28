class AddSortOrderAndAllowTypesToMEdgeProcesses < ActiveRecord::Migration[8.0]
  def change
    # 表示順
    add_column :m_edge_processes, :sort_order, :integer, null: false, default: 0, comment: "表示順（昇順）"

    # 許可タイプ集合（例: {"board": true, "lumber": false}）
    add_column :m_edge_processes, :allow_types, :jsonb, null: false, default: {}, comment: "許可タイプ（JSONオブジェクト）"

    # allow_types は常に JSON オブジェクトであることを保証
    add_check_constraint :m_edge_processes,
                         "jsonb_typeof(allow_types) = 'object'",
                         name: "m_edge_processes_allow_types_is_object"

    # 並び替えでよく使うならインデックス推奨（任意）
    add_index :m_edge_processes, :sort_order

    # JSONB をキー存在で検索するなら GIN も（任意）
    add_index :m_edge_processes, :allow_types, using: :gin
  end
end
