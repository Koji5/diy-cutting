class CreateQuoteItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_items do |t|
      t.bigint  :quote_id,                 null: false
      t.integer :line_no,  limit: 2,       null: false

      t.string  :material_category_code, limit: 10,  null: false
      t.string  :material_code,          limit: 16, null: false
      t.string  :shape_code,             limit: 10, null: false
      t.string  :paint_type_code,        limit: 10

      t.decimal :thickness_mm, precision: 8, scale: 2, null: false
      t.decimal :width1_mm,   precision: 8, scale: 2, null: false
      t.decimal :width2_mm,   precision: 8, scale: 2
      t.decimal :length_mm,   precision: 8, scale: 2, null: false

      t.jsonb   :shape_json,        null: false, default: {}
      t.jsonb   :corner_proc_json,  null: false, default: {}
      t.jsonb   :hole_json,         null: false, default: {}
      t.jsonb   :sqhole_json,       null: false, default: {}
      t.jsonb   :edge_json,         null: false, default: {}
      t.jsonb   :paint_json,        null: false, default: {}

      t.integer :quantity,              null: false
      t.integer :shipping_size_class,   limit: 2
      t.text    :note

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── インデックス & ユニーク ──
    add_index :quote_items, :quote_id
    add_index :quote_items, [:quote_id, :line_no], unique: true
    add_index :quote_items, :material_category_code
    add_index :quote_items, :material_code
    add_index :quote_items, :shape_code
    add_index :quote_items, :paint_type_code

    # GIN インデックス（JSONB 全文検索用）
    add_index :quote_items, :corner_proc_json, using: :gin
    add_index :quote_items, :hole_json,        using: :gin
    add_index :quote_items, :sqhole_json,      using: :gin

    # ── 外部キー ──
    add_foreign_key :quote_items, :quotes,           column: :quote_id
    add_foreign_key :quote_items, :m_categories,
                    column: :material_category_code, primary_key: :code
    add_foreign_key :quote_items, :m_materials,
                    column: :material_code,          primary_key: :code
    add_foreign_key :quote_items, :m_shapes,
                    column: :shape_code,             primary_key: :code
    add_foreign_key :quote_items, :m_paint_types,
                    column: :paint_type_code,        primary_key: :code

    # ── CHECK 制約 (>0) ──
    execute <<~SQL
      ALTER TABLE quote_items
        ADD CONSTRAINT chk_positive_dims
        CHECK (
          thickness_mm > 0 AND width1_mm > 0 AND length_mm > 0 AND
          (width2_mm IS NULL OR width2_mm > 0) AND quantity > 0
        );
    SQL
  end
end
