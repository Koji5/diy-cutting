# db/migrate/XXXXXXXXXX_create_vendor_service_areas.rb
class CreateVendorServiceAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_service_areas, id: false do |t|
      t.bigint :vendor_id,        null: false   # FK → vendor_details.user_id
      t.string :prefecture_code,  null: false, limit: 2
      t.string :city_code,        null: false, limit: 5
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── 複合プライマリキー（重複防止） ──
    execute <<~SQL
      ALTER TABLE vendor_service_areas
        ADD CONSTRAINT vendor_service_areas_pkey
        PRIMARY KEY (vendor_id, prefecture_code, city_code);
    SQL

    # ── インデックス ──
    add_index :vendor_service_areas, :vendor_id
    add_index :vendor_service_areas, :prefecture_code
    add_index :vendor_service_areas, :city_code

    # ── 外部キー ──
    add_foreign_key :vendor_service_areas, :vendor_details,
                    column: :vendor_id, primary_key: :user_id, on_delete: :cascade

    add_foreign_key :vendor_service_areas, :m_prefectures,
                    column: :prefecture_code, primary_key: :code

    add_foreign_key :vendor_service_areas, :m_cities,
                    column: :city_code, primary_key: :code
  end
end
