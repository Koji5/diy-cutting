class CreateMPrefectures < ActiveRecord::Migration[8.0]
  def change
    create_table :m_prefectures,
                 id: false,                    # bigint id は不要
                 primary_key: :code do |t|     # PK を code に

      # ─── 列定義 ───
      t.column  :code,    :char,  limit: 2,  null: false     # '01'〜'47'
      t.string  :name_ja,          limit: 10, null: false
      t.string  :name_en,          limit: 20, null: false
      t.string  :kana,             limit: 20, null: false

      # ─── メタ列 ───
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true
      t.boolean    :deleted_flag,            null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }, index: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ─── インデックス & 制約 ───
    add_index :m_prefectures, :name_ja, unique: true

    execute <<~SQL
      ALTER TABLE m_prefectures
        ADD CONSTRAINT m_prefectures_code_chk
          CHECK (code BETWEEN '01' AND '47');
    SQL
  end
end