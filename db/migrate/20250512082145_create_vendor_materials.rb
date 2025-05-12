# db/migrate/XXXXXXXXXX_create_vendor_materials.rb
class CreateVendorMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_materials, id: false do |t|
      t.bigint :vendor_id,      null: false                # 業者 FK
      t.string :material_code,  null: false, limit: 16     # 材質 FK
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── 複合プライマリキー ──
    execute <<~SQL
      ALTER TABLE vendor_materials
        ADD CONSTRAINT vendor_materials_pkey
        PRIMARY KEY (vendor_id, material_code);
    SQL

    # ── インデックス ──
    add_index :vendor_materials, :vendor_id
    add_index :vendor_materials, :material_code

    # ── 外部キー ──
    add_foreign_key :vendor_materials, :vendor_details,
                    column: :vendor_id, primary_key: :user_id, on_delete: :cascade

    add_foreign_key :vendor_materials, :m_materials,
                    column: :material_code, primary_key: :code
  end
end
