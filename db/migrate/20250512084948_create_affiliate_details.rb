# db/migrate/XXXXXXXXXX_create_affiliate_details.rb
class CreateAffiliateDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :affiliate_details,
                 id: false,
                 primary_key: :user_id do |t|

      t.bigint :user_id, null: false                     # PK + FK(users)

      t.string  :name,             limit: 100, null: false
      t.string  :name_kana,        limit: 255
      t.string  :postal_code,      limit: 8,   null: false
      t.string  :prefecture_code,  limit: 2,   null: false
      t.string  :city_code,        limit: 5,   null: false
      t.string  :address_line,     limit: 200, null: false
      t.string  :phone_number,     limit: 30
      t.string  :invoice_number,   limit: 20, index: { unique: true }

      # 振込口座
      t.string  :bank_name,     limit: 100
      t.integer :account_type,  limit: 2          # 0=普通 1=当座
      t.string  :account_number, limit: 30
      t.string  :account_holder, limit: 100

      # 報酬管理
      t.decimal :commission_rate,  precision: 5,  scale: 2,  null: false, default: 3.00
      t.decimal :payout_threshold, precision: 18, scale: 4,  null: false, default: 5000
      t.decimal :unpaid_balance,   precision: 18, scale: 4,  null: false, default: 0
      t.datetime :last_paid_at

      # Stripe
      t.string  :stripe_account_id, limit: 255, null: false, index: true
      t.boolean :charges_enabled,   null: false, default: false
      t.boolean :payouts_enabled,   null: false, default: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ─── 外部キー ───
    add_foreign_key :affiliate_details, :users,
                    column: :user_id, primary_key: :id

    add_foreign_key :affiliate_details, :m_prefectures,
                    column: :prefecture_code, primary_key: :code
    add_foreign_key :affiliate_details, :m_cities,
                    column: :city_code, primary_key: :code

    # Stripe account は事前に UNIQUE(index) 済である前提
    add_foreign_key :affiliate_details, :stripe_accounts,
                    column: :stripe_account_id,
                    primary_key: :stripe_account_id
  end
end
