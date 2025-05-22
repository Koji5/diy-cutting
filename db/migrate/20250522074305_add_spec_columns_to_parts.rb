# db/migrate/XXXXXXXXXX_add_spec_columns_to_parts.rb
class AddSpecColumnsToParts < ActiveRecord::Migration[8.0]
  def change
    %i[parts part_snapshots].each do |tbl|
      change_table tbl, bulk: true do |t|
        t.column  :material_category_code, :string,  limit: 10, null: false
        t.column  :material_code,          :string,  limit: 16, null: false
        t.column  :shape_code,             :string,  limit: 8,  null: false
        t.column  :paint_type_code,        :string,  limit: 4

        t.decimal :thickness_mm, precision: 8, scale: 2, null: false
        t.decimal :width1_mm,    precision: 8, scale: 2, null: false
        t.decimal :width2_mm,    precision: 8, scale: 2
        t.decimal :length_mm,    precision: 8, scale: 2, null: false

        t.jsonb   :shape_json,          null: true, default: {}
        t.jsonb   :corner_proc_json,    null: true, default: {}
        t.jsonb   :hole_json,           null: true, default: {}
        t.jsonb   :sqhole_json,         null: true, default: {}
        t.jsonb   :edge_json,           null: true, default: {}
        t.jsonb   :paint_json,          null: true, default: {}

        t.text    :note

        t.boolean    :deleted_flag, default: false, null: false
        t.datetime   :deleted_at
        t.references :deleted_by, foreign_key: { to_table: :users }
        t.references :created_by, foreign_key: { to_table: :users }
        t.references :updated_by, foreign_key: { to_table: :users }
      end
    end

    # --------- 制約 -------------
    execute <<~SQL
      ALTER TABLE parts
        ADD CONSTRAINT chk_parts_dims_positive
          CHECK (thickness_mm>0 AND width1_mm>0 AND (width2_mm IS NULL OR width2_mm>0) AND length_mm>0);
      ALTER TABLE part_snapshots
        ADD CONSTRAINT chk_ps_dims_positive
          CHECK (thickness_mm>0 AND width1_mm>0 AND (width2_mm IS NULL OR width2_mm>0) AND length_mm>0);
    SQL

    # --------- 外部キー ----------
    add_foreign_key :parts, :m_categories,    column: :material_category_code, primary_key: :code
    add_foreign_key :parts, :m_materials,     column: :material_code,          primary_key: :code
    add_foreign_key :parts, :m_shapes,        column: :shape_code,             primary_key: :code
    add_foreign_key :parts, :m_paint_types,   column: :paint_type_code,        primary_key: :code

    add_foreign_key :part_snapshots, :m_categories,  column: :material_category_code, primary_key: :code
    add_foreign_key :part_snapshots, :m_materials,   column: :material_code,          primary_key: :code
    add_foreign_key :part_snapshots, :m_shapes,      column: :shape_code,             primary_key: :code
    add_foreign_key :part_snapshots, :m_paint_types, column: :paint_type_code,        primary_key: :code

    # --------- GIN インデックス ---
    %i[parts part_snapshots].each do |tbl|
      add_index tbl, :corner_proc_json, using: :gin
      add_index tbl, :hole_json,        using: :gin
      add_index tbl, :sqhole_json,      using: :gin
    end
  end
end
