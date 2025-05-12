class CreateMCities < ActiveRecord::Migration[8.0]
  def change
    create_table :m_cities,
                 id: false,                   # bigint id を削除
                 primary_key: :code do |t|    # PK を code に

      # ─── 本体カラム ───
      t.column :code,            :char,  limit: 5,  null: false   # '13113' 等
      t.column :prefecture_code, :char,  limit: 2,  null: false
      t.string :name_ja,                     limit: 100, null: false
      t.string :name_kana,                   limit: 100
      t.string :name_en,                     limit: 100
      t.integer :sort_no,        limit: 2                         # smallint 相当

      # ─── メタ情報 ───
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true
      t.boolean    :deleted_flag,            null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }, index: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ─── インデックス & 外部キー ───
    add_index :m_cities, :prefecture_code
    add_foreign_key :m_cities, :m_prefectures,
                    column: :prefecture_code, primary_key: :code
  end
end