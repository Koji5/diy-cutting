class CreateArticleLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :article_likes do |t|
      t.bigint   :article_id, null: false
      t.bigint   :user_id,    null: false
      t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end

    # ─── 参照制約 ─────────────────────────────
    add_foreign_key :article_likes, :articles
    add_foreign_key :article_likes, :users

    # ─── インデックス ──────────────────────────
    add_index :article_likes, :article_id
    add_index :article_likes, :user_id
    add_index :article_likes, %i[article_id user_id],
              unique: true,
              name:   :uq_article_likes_article_user
  end
end
