class CreateMemberDetails < ActiveRecord::Migration[8.0]
  def change
    # PK を users.id と共有する 1:1 テーブル
    create_table :member_details,
                 id: false,
                 primary_key: :user_id do |t|

      t.bigint :user_id, null: false                         # ← users.id と同値

      t.string  :nickname, limit: 50
      t.string  :icon_url

      t.integer :legal_type,  limit: 2, null: false          # 0=individual 1=corporation
      t.string  :legal_name,           null: false
      t.string  :legal_name_kana

      t.date    :birthday
      t.string  :gender, limit: 1                            # 'M','F','O'…

      # ― 請求先 ―
      t.string  :billing_postal_code,    limit: 20
      t.string  :billing_prefecture_code, limit: 2
      t.string  :billing_city_code,        limit: 5, null: false
      t.string  :billing_address_line,     limit: 200, null: false
      t.string  :billing_department,       limit: 100
      t.string  :billing_phone_number,     limit: 30

      # ― 発送先 ―
      t.bigint  :primary_shipping_id                       # FK 後付け

      # ― その他 ―
      t.integer :role, limit: 2, null: false,  default: 4  # 4=general
      t.string  :stripe_customer_id, index: true
      t.bigint  :registered_affiliate_id, index: true

      # ― メタ ―
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ------- 外部キー -------
    add_foreign_key :member_details, :users, column: :user_id
    add_foreign_key :member_details, :users,
                    column: :registered_affiliate_id

    add_foreign_key :member_details, :m_prefectures,
                    column: :billing_prefecture_code, primary_key: :code
    add_foreign_key :member_details, :m_cities,
                    column: :billing_city_code,       primary_key: :code

    # 役割整合 CHECK（任意）
    execute <<~SQL
      ALTER TABLE member_details
        ADD CONSTRAINT chk_member_role CHECK (role = 4);
    SQL
  end
end
