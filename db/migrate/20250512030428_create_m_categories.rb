class CreateMCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :m_categories,
                 id: false,
                 primary_key: :code do |t|

      t.string  :code,    limit: 10, null: false          # PK
      t.string  :name_ja, limit: 20, null: false
      t.string  :name_en, limit: 20, null: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # UNIQUE インデックス
    add_index :m_categories, :name_ja, unique: true
    add_index :m_categories, :name_en, unique: true
  end
end
