class CreateVendorServicePrefectures < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_service_prefectures do |t|
      # 業者 (vendor_details.user_id) への外部キー
      t.bigint :vendor_id, null: false

      # 都道府県コード (m_prefectures.code の2桁 CHAR)
      t.column :prefecture_code, :char, limit: 2, null: false

      t.timestamps
    end

    # ──────────── インデックス・制約 ────────────
    # 業者 × 都道府県 の組み合わせを一意に
    add_index :vendor_service_prefectures,
              %i[vendor_id prefecture_code],
              unique: true,
              name: :idx_vsp_unique

    # 外部キー: 業者 → vendor_details(user_id)
    add_foreign_key :vendor_service_prefectures,
                    :vendor_details,
                    column: :vendor_id,
                    primary_key: :user_id,
                    on_delete: :cascade

    # 外部キー: 都道府県 → m_prefectures(code)
    add_foreign_key :vendor_service_prefectures,
                    :m_prefectures,
                    column: :prefecture_code,
                    primary_key: :code
  end
end
