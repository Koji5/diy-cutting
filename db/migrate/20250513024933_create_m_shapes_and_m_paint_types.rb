# db/migrate/XXXXXXXXXX_create_m_shapes_and_m_paint_types.rb
class CreateMShapesAndMPaintTypes < ActiveRecord::Migration[8.0]
  def change
    # ────────────────── m_shapes ──────────────────
    create_table :m_shapes, id: false do |t|
      t.string :code,       limit: 10, null: false
      t.string :name_ja,    limit: 30, null: false
      t.string :name_en,    limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      t.text   :allow_shape_json,  array: true, null: false, default: []
      t.text   :allow_corner_json, array: true, null: false, default: []
      t.text   :allow_edge_json,   array: true, null: false, default: []

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    execute "ALTER TABLE m_shapes ADD PRIMARY KEY (code);"
    add_index :m_shapes, :name_ja, unique: true
    add_index :m_shapes, :name_en, unique: true

    # ────────────────── m_paint_types ──────────────────
    create_table :m_paint_types, id: false do |t|
      t.string :code,       limit: 10, null: false
      t.string :name_ja,    limit: 30, null: false
      t.string :name_en,    limit: 30, null: false
      t.string :description_ja, limit: 80
      t.string :description_en, limit: 80
      t.text   :allow_paint_json, array: true, null: false, default: []

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    execute "ALTER TABLE m_paint_types ADD PRIMARY KEY (code);"
    add_index :m_paint_types, :name_ja, unique: true
    add_index :m_paint_types, :name_en, unique: true
  end
end
