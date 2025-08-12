# db/migrate/XXXXXXXXXXXXXX_create_m_paint_finishes_and_glosses.rb
class CreateMPaintFinishesAndGlosses < ActiveRecord::Migration[8.0]
  def up
    # --- m_paint_finishes -------------------------------------------------
    create_table :m_paint_finishes, primary_key: :code, id: :string, limit: 6 do |t|
      t.string  :name_ja, limit: 30, null: false
      t.string  :name_en, limit: 30, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80

      t.references :created_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true
      t.references :updated_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true
      t.boolean :deleted_flag, null: false, default: false
      t.datetime :deleted_at, precision: 6
      t.references :deleted_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true

      # timestamp(6) DEFAULT CURRENT_TIMESTAMP NOT NULL
      t.timestamps precision: 6, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :m_paint_finishes, :name_ja, unique: true
    add_index :m_paint_finishes, :name_en, unique: true

    # --- m_paint_glosses --------------------------------------------------
    create_table :m_paint_glosses, primary_key: :code, id: :string, limit: 6 do |t|
      t.string  :name_ja, limit: 30, null: false
      t.string  :name_en, limit: 30, null: false
      t.string  :description_ja, limit: 80
      t.string  :description_en, limit: 80

      t.references :created_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true
      t.references :updated_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true
      t.boolean :deleted_flag, null: false, default: false
      t.datetime :deleted_at, precision: 6
      t.references :deleted_by, type: :bigint, foreign_key: { to_table: :accounts }, index: true

      t.timestamps precision: 6, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :m_paint_glosses, :name_ja, unique: true
    add_index :m_paint_glosses, :name_en, unique: true
  end

  def down
    drop_table :m_paint_glosses
    drop_table :m_paint_finishes
  end
end
