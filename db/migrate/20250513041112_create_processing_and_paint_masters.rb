# db/migrate/XXXXXXXXXX_create_processing_and_paint_masters.rb
class CreateProcessingAndPaintMasters < ActiveRecord::Migration[8.0]
  def change
    # 共通メタ列ヘルパ
    def meta_columns(t)
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ───────── 1. m_corner_processes ─────────
    create_table :m_corner_processes, id: false do |t|
      t.string :code, limit: 10, null: false
      t.string :name_ja, limit: 30, null: false
      t.string :name_en, limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      t.text   :allow_corner_proc_json, array: true, null: false, default: []
      meta_columns(t)
    end
    execute "ALTER TABLE m_corner_processes ADD PRIMARY KEY (code);"
    add_index :m_corner_processes, :name_ja, unique: true
    add_index :m_corner_processes, :name_en, unique: true

    # ───────── 2. m_hole_diameters ─────────
    create_table :m_hole_diameters, id: false do |t|
      t.string  :code, limit: 10, null: false
      t.decimal :hole_mm, precision: 8, scale: 2, null: false
      t.string  :name_ja, limit: 20, null: false
      t.string  :name_en, limit: 6,  null: false
      meta_columns(t)
    end
    execute "ALTER TABLE m_hole_diameters ADD PRIMARY KEY (code);"

    # ───────── 3. m_edge_processes ─────────
    create_table :m_edge_processes, id: false do |t|
      t.string :code, limit: 10, null: false
      t.string :name_ja, limit: 20, null: false
      t.string :name_en, limit: 10, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      meta_columns(t)
    end
    execute "ALTER TABLE m_edge_processes ADD PRIMARY KEY (code);"

    # ───────── 4. m_paint_surfaces ─────────
    create_table :m_paint_surfaces, id: false do |t|
      t.string :code, limit: 6, null: false
      t.string :name_ja, limit: 30, null: false
      t.string :name_en, limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      meta_columns(t)
    end
    execute "ALTER TABLE m_paint_surfaces ADD PRIMARY KEY (code);"
    add_index :m_paint_surfaces, :name_ja, unique: true
    add_index :m_paint_surfaces, :name_en, unique: true

    # ───────── 5. m_paint_colors ─────────
    create_table :m_paint_colors, id: false do |t|
      t.string :code, limit: 6, null: false
      t.string :name_ja, limit: 30, null: false
      t.string :name_en, limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      meta_columns(t)
    end
    execute "ALTER TABLE m_paint_colors ADD PRIMARY KEY (code);"
    add_index :m_paint_colors, :name_ja, unique: true
    add_index :m_paint_colors, :name_en, unique: true

    # ───────── 6. m_grain_finishes ─────────
    create_table :m_grain_finishes, id: false do |t|
      t.string :code, limit: 6, null: false
      t.string :name_ja, limit: 30, null: false
      t.string :name_en, limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      meta_columns(t)
    end
    execute "ALTER TABLE m_grain_finishes ADD PRIMARY KEY (code);"

    # ───────── 7. m_glosses ─────────
    create_table :m_glosses, id: false do |t|
      t.string  :code, limit: 6, null: false
      t.string  :name_ja, limit: 30, null: false
      t.string  :name_en, limit: 30, null: false
      t.integer :gloss_pct, limit: 2, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80
      meta_columns(t)
    end
    execute "ALTER TABLE m_glosses ADD PRIMARY KEY (code);"
    execute <<~SQL
      ALTER TABLE m_glosses
        ADD CONSTRAINT chk_gloss_pct
        CHECK (gloss_pct BETWEEN 0 AND 100);
    SQL
  end
end
