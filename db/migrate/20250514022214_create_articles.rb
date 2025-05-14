class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      # --- ポリモーフィック投稿者 ---
      t.string  :author_type, null: false, limit: 20
      t.bigint  :author_id,   null: false

      # --- 記事属性 ---
      t.integer :category,    null: false, limit: 2            # smallint 相当
      t.string  :title,       null: false, limit: 150
      t.jsonb   :content_blocks, null: false, default: '{}'
      t.bigint  :order_id                                   # 任意で紐づく注文

      # --- カウンタ列 ---
      t.integer :likes_count,    null: false, default: 0
      t.integer :replies_count,  null: false, default: 0
      t.integer :views_count,    null: false, default: 0

      # --- ステータス ---
      t.datetime :published_at
      t.boolean  :is_draft,      null: false, default: false

      # --- メタ列（共通） ---
      t.boolean  :deleted_flag,  null: false, default: false
      t.datetime :deleted_at
      t.bigint   :deleted_by_id
      t.bigint   :created_by_id
      t.bigint   :updated_by_id
      t.timestamps  default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ---------- INDEX ----------
    add_index :articles, %i[author_type author_id]
    add_index :articles, :order_id
    add_index :articles, :likes_count
    add_index :articles, :replies_count
    add_index :articles, :views_count
    add_index :articles, :content_blocks, using: :gin

    # ---------- FOREIGN KEY ----------
    add_foreign_key :articles, :orders, column: :order_id
    add_foreign_key :articles, :users,  column: :created_by_id
    add_foreign_key :articles, :users,  column: :updated_by_id
    add_foreign_key :articles, :users,  column: :deleted_by_id
  end
end
