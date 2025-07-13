class CreateMemberProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :member_profiles do |t|
      t.references :account, null: false, foreign_key: { to_table: :accounts }

      t.string :billing_postal_code, limit: 20
      t.string :billing_prefecture_code, limit: 2
      t.string :billing_city_code, limit: 5, null: false
      t.string :billing_address_line, limit: 200, null: false
      t.string :billing_department, limit: 100
      t.string :billing_phone_number, limit: 30

      t.string :stripe_customer_id
      t.references :registered_affiliate, foreign_key: { to_table: :accounts }
      t.references :created_by, foreign_key: { to_table: :accounts }
      t.references :updated_by, foreign_key: { to_table: :accounts }
      t.references :deleted_by, foreign_key: { to_table: :accounts }

      t.boolean :deleted_flag, null: false, default: false
      t.datetime :deleted_at
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false

      t.integer :membership_plan, null: false, default: 0
    end

    add_foreign_key :member_profiles, :m_cities, column: :billing_city_code, primary_key: :code
    add_foreign_key :member_profiles, :m_prefectures, column: :billing_prefecture_code, primary_key: :code

    add_index :member_profiles, :stripe_customer_id
  end
end
