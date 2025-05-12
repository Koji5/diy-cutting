class CreateVendorDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_details,
                 id: false,
                 primary_key: :user_id do |t|

      t.bigint :user_id, null: false                           # PK + FK (users)

      t.string  :nickname,             limit: 50
      t.string  :profile_icon_url,     limit: 500

      # 基本情報
      t.string  :vendor_name,          limit: 100, null: false
      t.string  :vendor_name_kana,     limit: 100
      t.string  :invoice_number,       limit: 20, index: { unique: true }

      # 担当者
      t.string  :contact_person_name,  limit: 80,  null: false
      t.string  :contact_person_kana,  limit: 80
      t.string  :contact_phone_number, limit: 20

      # 事業所住所
      t.string  :office_postal_code,     limit: 8
      t.string  :office_prefecture_code, limit: 2, null: false
      t.string  :office_city_code,       limit: 5, null: false
      t.string  :office_address_line,    limit: 200, null: false
      t.string  :office_phone_number,    limit: 20

      # 口座
      t.string  :bank_name,         limit: 60
      t.integer :account_type,      limit: 2          # 0=普通 1=当座
      t.string  :account_number,    limit: 20
      t.string  :account_name,      limit: 100

      # 出荷元住所（JSONB）
      t.jsonb :shipping_base_address_json

      t.text   :notes

      # Stripe
      t.string  :stripe_account_id,  null: false, limit: 255, index: true
      t.boolean :charges_enabled,    null: false, default: false
      t.boolean :payouts_enabled,    null: false, default: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ---------- 外部キー ----------
    add_foreign_key :vendor_details, :users, column: :user_id

    add_foreign_key :vendor_details, :m_prefectures,
                    column: :office_prefecture_code, primary_key: :code
    add_foreign_key :vendor_details, :m_cities,
                    column: :office_city_code,       primary_key: :code

    add_foreign_key :vendor_details, :stripe_accounts,
                    column: :stripe_account_id, primary_key: :stripe_account_id
  end
end
