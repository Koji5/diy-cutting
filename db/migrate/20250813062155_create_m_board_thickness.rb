class CreateMBoardThickness < ActiveRecord::Migration[8.0]
  def change
    # まずは通常のカラムを作る（整数IDは要らないので id: false）
    create_table :m_board_thickness, id: false do |t|
      t.string  :code,         limit: 10, null: false
      t.decimal :thickness_mm, precision: 8, scale: 2, null: false
      t.string  :name_ja,      limit: 20, null: false
      t.string  :name_en,      limit: 6,  null: false

      t.bigint  :created_by_id
      t.bigint  :updated_by_id
      t.boolean :deleted_flag, default: false, null: false
      t.datetime :deleted_at,  precision: 6
      t.bigint  :deleted_by_id

      # timestamp(6) + DEFAULT CURRENT_TIMESTAMP
      t.datetime :created_at, precision: 6, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :updated_at, precision: 6, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    # 主キーを code に設定（PostgreSQL のデフォ名 m_board_thickness_pkey が付きます）
    execute "ALTER TABLE m_board_thickness ADD PRIMARY KEY (code);"

    # 外部キー制約
    add_foreign_key :m_board_thickness, :accounts, column: :created_by_id
    add_foreign_key :m_board_thickness, :accounts, column: :updated_by_id
    add_foreign_key :m_board_thickness, :accounts, column: :deleted_by_id

    # インデックス
    add_index :m_board_thickness, :created_by_id
    add_index :m_board_thickness, :updated_by_id
    add_index :m_board_thickness, :deleted_by_id
  end
end
