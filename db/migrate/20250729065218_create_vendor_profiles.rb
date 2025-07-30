class CreateVendorProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_profiles do |t|
      t.references :account, null: false, foreign_key: true

      t.string  :invoice_number,      limit: 20
      t.string  :contact_person_name, limit: 80
      t.string  :contact_person_kana, limit: 80
      t.string  :contact_phone_number, limit: 20

      t.string  :office_postal_code,     limit: 7
      t.string  :office_prefecture_code, limit: 2
      t.string  :office_city_code,       limit: 5, null: false
      t.string  :office_address_line,    limit: 200, null: false
      t.string  :office_department,      limit: 200
      t.string  :office_phone_number,    limit: 20
      t.string  :office_email,           limit: 200
      t.text    :description

      t.integer :coverage_scope, null: false, default: 0

      t.string  :bank_name,      limit: 60
      t.integer :account_type,   limit: 2
      t.string  :account_number, limit: 20
      t.string  :account_name,   limit: 100

      t.boolean :charges_enabled, null: false, default: false
      t.boolean :payouts_enabled, null: false, default: false

      t.bigint  :created_by_id
      t.bigint  :updated_by_id
      t.boolean :deleted_flag, null: false, default: false
      t.datetime :deleted_at
      t.bigint  :deleted_by_id

      t.timestamps
    end

    # 外部キー制約
    add_foreign_key :vendor_profiles, :accounts, column: :created_by_id
    add_foreign_key :vendor_profiles, :accounts, column: :updated_by_id
    add_foreign_key :vendor_profiles, :accounts, column: :deleted_by_id
    add_foreign_key :vendor_profiles, :m_cities, column: :office_city_code, primary_key: :code
    add_foreign_key :vendor_profiles, :m_prefectures, column: :office_prefecture_code, primary_key: :code

    # インデックス
    add_index :vendor_profiles, :invoice_number, unique: true
    add_index :vendor_profiles, :coverage_scope
    add_index :vendor_profiles, :created_by_id
    add_index :vendor_profiles, :updated_by_id
    add_index :vendor_profiles, :deleted_by_id
    add_index :vendor_profiles, :office_email
  end
end
