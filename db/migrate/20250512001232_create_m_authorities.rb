class CreateMAuthorities < ActiveRecord::Migration[8.0]
  def change
    create_table :m_authorities,
                 id: false,                     # bigint id を消す
                 primary_key: :code do |t|      # 主キーを code に

      # ───── 業務カラム ─────
      t.string  :code,       limit: 30, null: false             # PK 列
      t.string  :name_ja,    limit: 60, null: false
      t.jsonb   :default_roles                                   # ["admin", …]
      t.boolean :active_flag,               null: false, default: true

      # ───── メタ情報 ─────
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true
      t.boolean    :deleted_flag,            null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }, index: true

      # created_at / updated_at：DB 側で CURRENT_TIMESTAMP
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ───── インデックス ─────
    add_index :m_authorities, :active_flag
  end
end
