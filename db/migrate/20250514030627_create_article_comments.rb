class CreateArticleComments < ActiveRecord::Migration[8.0]
  def change
    create_table :article_comments do |t|
      t.bigint  :article_id,   null: false
      t.bigint  :parent_id                         # NULL＝第1階層
      t.string  :author_type, limit: 20, null: false
      t.bigint  :author_id,    null: false
      t.text    :body,         null: false

      # メタ列
      t.boolean    :deleted_flag,  null: false, default: false
      t.datetime   :deleted_at
      t.bigint     :deleted_by_id
      t.bigint     :created_by_id
      t.bigint     :updated_by_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # --- インデックス ---
    add_index :article_comments, :article_id
    add_index :article_comments, :parent_id
    add_index :article_comments, :author_id
    add_index :article_comments, [:author_type, :author_id],
              name: :idx_article_comments_author_polymorphic
    add_index :article_comments, :created_by_id
    add_index :article_comments, :updated_by_id
    add_index :article_comments, :deleted_by_id

    # --- 外部キー ---
    add_foreign_key :article_comments, :articles
    add_foreign_key :article_comments, :article_comments,
                    column: :parent_id
    add_foreign_key :article_comments, :users,
                    column: :created_by_id
    add_foreign_key :article_comments, :users,
                    column: :updated_by_id
    add_foreign_key :article_comments, :users,
                    column: :deleted_by_id

    # --- CHECK 制約 (ポリモーフィック先を限定) ---
    add_check_constraint :article_comments,
      "author_type IN ('MemberDetail','VendorDetail','AdminDetail','AffiliateDetail')",
      name: :chk_article_comments_author_type

    # --- 代表的な長さ制限 ----
    change_column :article_comments, :body, :text, limit: 10_000
  end
end
