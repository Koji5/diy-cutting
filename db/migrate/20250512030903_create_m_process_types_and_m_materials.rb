class CreateMProcessTypesAndMMaterials < ActiveRecord::Migration[8.0]
  def change
    # ───────── m_process_types ─────────
    create_table :m_process_types,
                 id: false,
                 primary_key: :code do |t|

      t.string  :code,           limit: 10, null: false             # PK
      t.string  :category_code,  limit: 10, null: false
      t.string  :name_ja,        limit: 40, null: false
      t.string  :name_en,        limit: 40, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80
      t.string  :jis_iso,        limit: 12

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :m_process_types, :category_code
    add_index :m_process_types, :name_ja, unique: true
    add_index :m_process_types, :name_en, unique: true
    add_foreign_key :m_process_types, :m_categories,
                    column: :category_code, primary_key: :code

    # ───────── m_materials ─────────
    create_table :m_materials,
                 id: false,
                 primary_key: :code do |t|

      t.string  :code,          limit: 16, null: false
      t.string  :category_code, limit: 10, null: false
      t.string  :name_ja,       limit: 40, null: false
      t.string  :name_en,       limit: 40, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80
      t.string  :jis_iso,       limit: 12
      t.decimal :density_kg_per_m3, precision: 8, scale: 2, null: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :m_materials, :category_code
    add_index :m_materials, :name_ja, unique: true
    add_index :m_materials, :name_en, unique: true
    add_foreign_key :m_materials, :m_categories,
                    column: :category_code, primary_key: :code
  end
end
