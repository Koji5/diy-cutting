class CreateVendorCapabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_capabilities, id: false do |t|
      t.bigint :vendor_id,       null: false   # FK → vendor_details.user_id
      t.string :capability_code, null: false, limit: 16  # FK → m_process_types.code
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ─── 複合プライマリキー ───
    execute "ALTER TABLE vendor_capabilities ADD PRIMARY KEY (vendor_id, capability_code);"

    # ─── インデックス ───
    add_index :vendor_capabilities, :vendor_id
    add_index :vendor_capabilities, :capability_code

    # ─── 外部キー ───
    add_foreign_key :vendor_capabilities, :vendor_details,
                    column: :vendor_id, primary_key: :user_id, on_delete: :cascade

    add_foreign_key :vendor_capabilities, :m_process_types,
                    column: :capability_code, primary_key: :code
  end
end
