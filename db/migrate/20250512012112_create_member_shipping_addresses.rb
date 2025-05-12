class CreateMemberShippingAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :member_shipping_addresses do |t|
      t.bigint  :member_id, null: false                     # member_details.user_id

      t.string  :label,           limit: 50
      t.string  :recipient_name,  limit: 100, null: false
      t.string  :postal_code,     limit: 8,  null: false
      t.string  :prefecture_code, limit: 2,  null: false
      t.string  :city_code,       limit: 5,  null: false
      t.string  :address_line,    limit: 200, null: false
      t.string  :phone_number,    limit: 20

      t.boolean :is_default, null: false, default: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ------- 外部キー -------
    add_index :member_shipping_addresses, :member_id
    add_foreign_key :member_shipping_addresses, :member_details,
                    column: :member_id,
                    primary_key: :user_id,
                    on_delete: :cascade

    add_foreign_key :member_shipping_addresses, :m_prefectures,
                    column: :prefecture_code, primary_key: :code
    add_foreign_key :member_shipping_addresses, :m_cities,
                    column: :city_code,       primary_key: :code

    # 会員 1 人につきデフォルトは 0〜1 件に制限
    execute <<~SQL
      CREATE UNIQUE INDEX uq_member_default_address
        ON member_shipping_addresses (member_id)
        WHERE is_default = true;
    SQL
  end
end