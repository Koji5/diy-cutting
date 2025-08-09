class AddMinimalColumnsToPartreworkPartSnapshotsToNewSchemareworkPartsToNewSchema < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # --- 1) 旧FKを外す ------------------------------------------------
    remove_foreign_key :parts, column: :material_category_code rescue nil
    remove_foreign_key :parts, column: :material_code          rescue nil
    remove_foreign_key :parts, column: :shape_code             rescue nil
    remove_foreign_key :parts, column: :paint_type_code        rescue nil
    remove_foreign_key :parts, column: :origin_owner_id        rescue nil

    # --- 2) 旧インデックスを外す --------------------------------------
    remove_index :parts, name: "index_parts_on_corner_proc_json" rescue nil
    remove_index :parts, name: "index_parts_on_hole_json"        rescue nil
    remove_index :parts, name: "index_parts_on_sqhole_json"      rescue nil
    # account_id / created_by_id / updated_by_id / deleted_by_id / origin_snapshot_id は維持

    # --- 3) 旧チェック制約を外す --------------------------------------
    execute "ALTER TABLE parts DROP CONSTRAINT IF EXISTS chk_parts_dims_positive"

    # --- 4) 旧カラムを削除 --------------------------------------------
    %i[
      material_category_code material_code shape_code paint_type_code
      thickness_mm width1_mm width2_mm length_mm
      shape_json corner_proc_json hole_json sqhole_json edge_json paint_json
      camera_state origin_owner_id
    ].each do |col|
      remove_column :parts, col if column_exists?(:parts, col)
    end

    # --- 5) 新カラム: shape_type_code を追加（まずは NULL 可） ---------
    add_column :parts, :shape_type_code, :string, limit: 12 unless column_exists?(:parts, :shape_type_code)

    # インデックス
    add_index :parts, :shape_type_code,
              algorithm: :concurrently,
              name: "index_parts_on_shape_type_code" unless index_exists?(:parts, :shape_type_code, name: "index_parts_on_shape_type_code")

    # --- 6) 新FK -------------------------------------------------------
    # shape_type_code → m_shape_types(code)
    unless foreign_key_exists?(:parts, :m_shape_types, column: :shape_type_code, primary_key: :code)
      add_foreign_key :parts, :m_shape_types,
                      column: :shape_type_code, primary_key: :code, validate: false
      # 後でデータ移行後に VALIDATE してください
    end

    # origin_snapshot_id → part_snapshots(id)
    unless foreign_key_exists?(:parts, :part_snapshots, column: :origin_snapshot_id)
      add_foreign_key :parts, :part_snapshots,
                      column: :origin_snapshot_id, validate: false
      # 後で VALIDATE してください
    end
  end

  def down
    # --- 新FKの解除 ---
    remove_foreign_key :parts, column: :origin_snapshot_id rescue nil
    remove_foreign_key :parts, column: :shape_type_code     rescue nil

    # --- 新インデックスの解除 ---
    remove_index :parts, name: "index_parts_on_shape_type_code" rescue nil

    # --- 新カラムの削除 ---
    remove_column :parts, :shape_type_code if column_exists?(:parts, :shape_type_code)

    # --- 旧カラムの再作成（最低限・NULL許容） ---
    add_column :parts, :material_category_code, :string, limit: 10 rescue nil
    add_column :parts, :material_code,          :string, limit: 16 rescue nil
    add_column :parts, :shape_code,             :string, limit: 10 rescue nil
    add_column :parts, :paint_type_code,        :string, limit: 4  rescue nil
    add_column :parts, :thickness_mm, :decimal, precision: 8, scale: 2 rescue nil
    add_column :parts, :width1_mm,   :decimal, precision: 8, scale: 2 rescue nil
    add_column :parts, :width2_mm,   :decimal, precision: 8, scale: 2 rescue nil
    add_column :parts, :length_mm,   :decimal, precision: 8, scale: 2 rescue nil
    add_column :parts, :shape_json,       :jsonb, default: {} rescue nil
    add_column :parts, :corner_proc_json, :jsonb, default: {} rescue nil
    add_column :parts, :hole_json,        :jsonb, default: {} rescue nil
    add_column :parts, :sqhole_json,      :jsonb, default: {} rescue nil
    add_column :parts, :edge_json,        :jsonb, default: {} rescue nil
    add_column :parts, :paint_json,       :jsonb, default: {} rescue nil
    add_column :parts, :camera_state,     :jsonb               rescue nil
    add_column :parts, :origin_owner_id,  :bigint              rescue nil

    # --- 旧チェック制約を復元（簡易） ---
    execute <<~SQL
      ALTER TABLE parts
      ADD CONSTRAINT chk_parts_dims_positive
      CHECK (
        (thickness_mm > 0)::boolean
        AND (width1_mm > 0)::boolean
        AND (width2_mm IS NULL OR width2_mm > 0)::boolean
        AND (length_mm > 0)::boolean
      );
    SQL

    # --- 旧インデックスを戻す（必要最低限） ---
    add_index :parts, :corner_proc_json, using: :gin, name: "index_parts_on_corner_proc_json" rescue nil
    add_index :parts, :hole_json,        using: :gin, name: "index_parts_on_hole_json"        rescue nil
    add_index :parts, :sqhole_json,      using: :gin, name: "index_parts_on_sqhole_json"      rescue nil

    # --- 旧FKを戻す（NOT VALID） ---
    add_foreign_key :parts, :m_categories, column: :material_category_code, primary_key: :code, validate: false rescue nil
    add_foreign_key :parts, :m_materials,  column: :material_code,          primary_key: :code, validate: false rescue nil
    add_foreign_key :parts, :m_shapes,     column: :shape_code,             primary_key: :code, validate: false rescue nil
    add_foreign_key :parts, :m_paint_types,column: :paint_type_code,        primary_key: :code, validate: false rescue nil
    add_foreign_key :parts, :accounts,     column: :origin_owner_id,        validate: false    rescue nil
  end
end
