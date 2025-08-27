class CreateMSideProcesses < ActiveRecord::Migration[8.0]
  def up
    create_table :m_side_processes, id: false do |t|
      # 主キー
      t.string  :code, limit: 10, null: false

      # 表示名・説明
      t.string  :name_ja, limit: 30, null: false
      t.string  :name_en, limit: 30, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80

      # 監査系
      t.bigint  :created_by_id
      t.bigint  :updated_by_id
      t.boolean :deleted_flag, null: false, default: false
      t.timestamp :deleted_at, precision: 6
      t.bigint  :deleted_by_id

      # タイムスタンプ（デフォルト CURRENT_TIMESTAMP）
      t.timestamp :created_at, null: false, precision: 6, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamp :updated_at, null: false, precision: 6, default: -> { "CURRENT_TIMESTAMP" }
    end

    # 主キー制約（code）
    execute <<~SQL
      ALTER TABLE m_side_processes
      ADD CONSTRAINT m_side_processes_pkey PRIMARY KEY (code);
    SQL

    # 外部キー（accounts.id）
    add_foreign_key :m_side_processes, :accounts, column: :created_by_id, name: "fk_m_side_processes_created_by"
    add_foreign_key :m_side_processes, :accounts, column: :updated_by_id, name: "fk_m_side_processes_updated_by"
    add_foreign_key :m_side_processes, :accounts, column: :deleted_by_id, name: "fk_m_side_processes_deleted_by"

    # インデックス
    add_index :m_side_processes, :created_by_id
    add_index :m_side_processes, :updated_by_id
    add_index :m_side_processes, :deleted_by_id

    add_index :m_side_processes, :name_ja, unique: true
    add_index :m_side_processes, :name_en, unique: true
  end

  def down
    # 依存関係の順序を意識して削除
    remove_foreign_key :m_side_processes, column: :created_by_id
    remove_foreign_key :m_side_processes, column: :updated_by_id
    remove_foreign_key :m_side_processes, column: :deleted_by_id

    drop_table :m_side_processes
  end
end
