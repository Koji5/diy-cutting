class RemovePrefectureCodeFromVendorServiceAreas < ActiveRecord::Migration[8.0]
  def change
    # ── 1. 既存の外部キー・インデックス・主キーを整理 ──
    # prefecture_code への外部キーが残っている場合は削除
    if foreign_key_exists?(:vendor_service_areas, :m_prefectures, column: :prefecture_code)
      remove_foreign_key :vendor_service_areas, column: :prefecture_code
    end

    # prefecture_code を含むインデックスがあれば削除
    if index_exists?(:vendor_service_areas, :prefecture_code)
      remove_index :vendor_service_areas, column: :prefecture_code
    end
    if index_exists?(:vendor_service_areas, %i[vendor_id prefecture_code city_code],
                     name: "vendor_service_areas_pkey")
      # 旧・複合PKを先に外す
      remove_index :vendor_service_areas, name: "vendor_service_areas_pkey"
    end

    # ── 2. カラムを削除 ──
    remove_column :vendor_service_areas, :prefecture_code, :char, limit: 2

    # ── 3. 必要なユニーク制約を追加 ──
    # 「vendor_id × city_code」で一意になるようインデックス
    add_index :vendor_service_areas,
              %i[vendor_id city_code],
              unique: true,
              name: :idx_vsa_unique
  end
end
