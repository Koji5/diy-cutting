class AddMinimalColumnsToPartreworkPartSnapshotsToNewSchema < ActiveRecord::Migration[8.0]
  def up
    # --- 1) 旧FKを外す（存在チェック付き） ----------------------------
    remove_foreign_key :part_snapshots, column: :paint_type_code rescue nil
    remove_foreign_key :part_snapshots, column: :material_code rescue nil
    remove_foreign_key :part_snapshots, column: :material_category_code rescue nil
    remove_foreign_key :part_snapshots, column: :shape_code rescue nil
    remove_foreign_key :part_snapshots, column: :part_id rescue nil

    # users 参照のFKを外す（後で accounts 参照を付け直す）
    remove_foreign_key :part_snapshots, column: :created_by_id rescue nil
    remove_foreign_key :part_snapshots, column: :updated_by_id rescue nil
    remove_foreign_key :part_snapshots, column: :deleted_by_id rescue nil

    # --- 2) 旧インデックスを外す --------------------------------------
    remove_index :part_snapshots, name: "index_part_snapshots_on_checksum" rescue nil
    remove_index :part_snapshots, name: "index_part_snapshots_on_corner_proc_json" rescue nil
    remove_index :part_snapshots, name: "index_part_snapshots_on_hole_json" rescue nil
    remove_index :part_snapshots, name: "index_part_snapshots_on_sqhole_json" rescue nil
    remove_index :part_snapshots, name: "index_part_snapshots_on_origin_snapshot_id" rescue nil
    remove_index :part_snapshots, name: "index_part_snapshots_on_part_id" rescue nil
    # ※ account_id / created_by_id / updated_by_id / deleted_by_id / source_part_id / shape_type_code は維持

    # --- 3) 旧チェック制約を外す --------------------------------------
    # 寸法カラムを削除するため、関連するチェック制約を先にDROP
    execute "ALTER TABLE part_snapshots DROP CONSTRAINT IF EXISTS chk_ps_dims_positive"

    # --- 4) 旧カラムを削除 --------------------------------------------
    columns_to_drop = %i[
      part_id checksum material_category_code material_code shape_code paint_type_code
      thickness_mm width1_mm width2_mm length_mm
      shape_json corner_proc_json hole_json sqhole_json edge_json paint_json
      origin_snapshot_id origin_owner_id
    ]
    columns_to_drop.each do |col|
      remove_column :part_snapshots, col if column_exists?(:part_snapshots, col)
    end

    # --- 5) *_by_id の参照先を accounts に付け替え（NOT VALID） -------
    # 既存値は users.id の可能性があるため、一旦 NOT VALID で追加 → 後でデータ移行→VALIDATE
    add_foreign_key :part_snapshots, :accounts, column: :created_by_id, validate: false unless foreign_key_exists?(:part_snapshots, :accounts, column: :created_by_id)
    add_foreign_key :part_snapshots, :accounts, column: :updated_by_id, validate: false unless foreign_key_exists?(:part_snapshots, :accounts, column: :updated_by_id)
    add_foreign_key :part_snapshots, :accounts, column: :deleted_by_id, validate: false unless foreign_key_exists?(:part_snapshots, :accounts, column: :deleted_by_id)

    # ※ すでに存在しているはずのFK（維持）
    #   account_id → accounts(id)
    #   shape_type_code → m_shape_types(code)
    #   source_part_id → parts(id)
  end

  def down
    # downでは可能な範囲で戻すが、削除カラムの完全復元は困難なので最小限

    # accounts FK を外す
    remove_foreign_key :part_snapshots, column: :created_by_id rescue nil
    remove_foreign_key :part_snapshots, column: :updated_by_id rescue nil
    remove_foreign_key :part_snapshots, column: :deleted_by_id rescue nil

    # （必要なら）users へのFKを戻す
    add_foreign_key :part_snapshots, :users, column: :created_by_id, validate: false rescue nil
    add_foreign_key :part_snapshots, :users, column: :updated_by_id, validate: false rescue nil
    add_foreign_key :part_snapshots, :users, column: :deleted_by_id, validate: false rescue nil

    # 削除したカラムはここで再作成（デフォルトなし・NULL許容で最低限）
    add_column :part_snapshots, :part_id, :bigint rescue nil
    add_column :part_snapshots, :checksum, :string rescue nil
    add_column :part_snapshots, :material_category_code, :string, limit: 10 rescue nil
    add_column :part_snapshots, :material_code, :string, limit: 16 rescue nil
    add_column :part_snapshots, :shape_code, :string, limit: 8 rescue nil
    add_column :part_snapshots, :paint_type_code, :string, limit: 4 rescue nil
    add_column :part_snapshots, :thickness_mm, :decimal, precision: 8, scale: 2 rescue nil
    add_column :part_snapshots, :width1_mm, :decimal, precision: 8, scale: 2 rescue nil
    add_column :part_snapshots, :width2_mm, :decimal, precision: 8, scale: 2 rescue nil
    add_column :part_snapshots, :length_mm, :decimal, precision: 8, scale: 2 rescue nil
    add_column :part_snapshots, :shape_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :corner_proc_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :hole_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :sqhole_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :edge_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :paint_json, :jsonb, default: {} rescue nil
    add_column :part_snapshots, :origin_snapshot_id, :bigint rescue nil
    add_column :part_snapshots, :origin_owner_id, :bigint rescue nil

    # 簡易にインデックスを戻す（必要最低限）
    add_index :part_snapshots, :checksum, name: "index_part_snapshots_on_checksum" rescue nil
    add_index :part_snapshots, :origin_snapshot_id, name: "index_part_snapshots_on_origin_snapshot_id" rescue nil
    add_index :part_snapshots, :part_id, name: "index_part_snapshots_on_part_id" rescue nil
  end
end
