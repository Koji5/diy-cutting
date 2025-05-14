# db/migrate/20250514042946_create_affiliate_signups.rb
class CreateAffiliateSignups < ActiveRecord::Migration[8.0]
  def change
    create_table :affiliate_signups do |t|
      t.bigint  :affiliate_user_id, null: false          # 紹介元アフィリエイト
      t.bigint  :affiliate_click_id                     # クリックログ（任意）
      t.bigint  :signup_user_id,     null: false        # 登録ユーザー（会員）
      t.datetime :signup_at,         null: false, default: -> { 'CURRENT_TIMESTAMP' }

      # メタ -———
      t.boolean  :deleted_flag,      null: false, default: false
      t.datetime :deleted_at
      t.bigint   :deleted_by_id
      t.bigint   :created_by_id
      t.bigint   :updated_by_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ─── インデックス ──────────────────────────
    add_index :affiliate_signups, :affiliate_user_id
    add_index :affiliate_signups, :affiliate_click_id
    add_index :affiliate_signups, :signup_user_id,  unique: true

    # ─── 外部キー ────────────────────────────
    add_foreign_key :affiliate_signups, :users,
                    column: :affiliate_user_id
    add_foreign_key :affiliate_signups, :users,
                    column: :signup_user_id
    add_foreign_key :affiliate_signups, :h_affiliate_clicks,
                    column: :affiliate_click_id
    add_foreign_key :affiliate_signups, :users,
                    column: :created_by_id
    add_foreign_key :affiliate_signups, :users,
                    column: :updated_by_id
    add_foreign_key :affiliate_signups, :users,
                    column: :deleted_by_id
  end
end
