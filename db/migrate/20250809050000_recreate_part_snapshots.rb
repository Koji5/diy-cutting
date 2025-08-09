class RecreatePartSnapshots < ActiveRecord::Migration[8.0]
  # 併走環境で安全にindexを貼るため
  disable_ddl_transaction!

  def up
    # --- カラム追加（存在チェック付きで冪等に） ---
    add_column :part_snapshots, :account_id, :bigint, null: false unless column_exists?(:part_snapshots, :account_id)
    add_column :part_snapshots, :name, :string, limit: 50, null: false unless column_exists?(:part_snapshots, :name)
    add_column :part_snapshots, :shape_type_code, :string, limit: 12, null: false unless column_exists?(:part_snapshots, :shape_type_code)
    add_column :part_snapshots, :source_part_id, :bigint unless column_exists?(:part_snapshots, :source_part_id)

    # --- インデックス（同名が無ければ追加） ---
    add_index :part_snapshots, :account_id,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_account_id" unless index_exists?(:part_snapshots, :account_id, name: "index_part_snapshots_on_account_id")

    add_index :part_snapshots, :created_by_id,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_created_by_id" unless index_exists?(:part_snapshots, :created_by_id, name: "index_part_snapshots_on_created_by_id")

    add_index :part_snapshots, :updated_by_id,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_updated_by_id" unless index_exists?(:part_snapshots, :updated_by_id, name: "index_part_snapshots_on_updated_by_id")

    add_index :part_snapshots, :deleted_by_id,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_deleted_by_id" unless index_exists?(:part_snapshots, :deleted_by_id, name: "index_part_snapshots_on_deleted_by_id")

    add_index :part_snapshots, :source_part_id,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_source_part_id" unless index_exists?(:part_snapshots, :source_part_id, name: "index_part_snapshots_on_source_part_id")

    add_index :part_snapshots, :shape_type_code,
              algorithm: :concurrently,
              name: "index_part_snapshots_on_shape_type_code" unless index_exists?(:part_snapshots, :shape_type_code, name: "index_part_snapshots_on_shape_type_code")

    # --- 外部キー（validate: false → 後で validate） ---
    unless foreign_key_exists?(:part_snapshots, :accounts, column: :account_id)
      add_foreign_key :part_snapshots, :accounts, column: :account_id, validate: false
      validate_foreign_key :part_snapshots, :accounts
    end

    # shape_type_code → m_shape_types(code)
    unless foreign_key_exists?(:part_snapshots, :m_shape_types, column: :shape_type_code, primary_key: :code)
      add_foreign_key :part_snapshots, :m_shape_types,
                      column: :shape_type_code, primary_key: :code, validate: false
      validate_foreign_key :part_snapshots, :m_shape_types
    end

    # source_part_id → parts(id)
    unless foreign_key_exists?(:part_snapshots, :parts, column: :source_part_id)
      add_foreign_key :part_snapshots, :parts, column: :source_part_id, validate: false
      validate_foreign_key :part_snapshots, :parts
    end

    # 既存トリガ forbid_origin_update は触らない（origin_snapshot_id も温存）
  end

  def down
    # FKの削除（存在チェック付）
    remove_foreign_key :part_snapshots, column: :source_part_id if foreign_key_exists?(:part_snapshots, :parts, column: :source_part_id)
    remove_foreign_key :part_snapshots, column: :shape_type_code if foreign_key_exists?(:part_snapshots, :m_shape_types, column: :shape_type_code)
    remove_foreign_key :part_snapshots, column: :account_id if foreign_key_exists?(:part_snapshots, :accounts, column: :account_id)

    # インデックス削除
    remove_index :part_snapshots, name: "index_part_snapshots_on_shape_type_code" if index_exists?(:part_snapshots, :shape_type_code, name: "index_part_snapshots_on_shape_type_code")
    remove_index :part_snapshots, name: "index_part_snapshots_on_source_part_id" if index_exists?(:part_snapshots, :source_part_id, name: "index_part_snapshots_on_source_part_id")
    remove_index :part_snapshots, name: "index_part_snapshots_on_account_id" if index_exists?(:part_snapshots, :account_id, name: "index_part_snapshots_on_account_id")

    # カラム削除
    remove_column :part_snapshots, :source_part_id if column_exists?(:part_snapshots, :source_part_id)
    remove_column :part_snapshots, :shape_type_code if column_exists?(:part_snapshots, :shape_type_code)
    remove_column :part_snapshots, :name if column_exists?(:part_snapshots, :name)
    remove_column :part_snapshots, :account_id if column_exists?(:part_snapshots, :account_id)

    # 既存のトリガ/既存カラムは引き続き温存
  end
end
