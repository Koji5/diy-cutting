# db/migrate/XXXXXXXXXXXXXX_create_board_parts.rb
class CreateBoardParts < ActiveRecord::Migration[8.0]
  def up
    create_table :board_parts do |t|
      # 1:1 を担保（unique index）しつつ part 参照
      t.references :part, null: false, foreign_key: true, index: { unique: true }

      # コード類
      t.string :material_code,     limit: 16, null: false   # m_materials.code
      t.string :paint_type_code,   limit: 12, null: false   # m_paint_types.code
      t.string :paint_color_code,  limit: 12                # m_paint_colors.code
      t.string :paint_finish_code, limit: 12                # m_paint_finishes.code
      t.string :paint_gloss_code,  limit: 12                # m_paint_glosses.code

      # 寸法
      t.decimal :thickness_mm, precision: 8, scale: 2, null: false
      t.decimal :width_mm,     precision: 8, scale: 2, null: false
      t.decimal :length_mm,    precision: 8, scale: 2, null: false

      # 加工パラメータ（jsonb）
      t.jsonb :corner_json, default: {}
      t.jsonb :side_json,   default: {}
      t.jsonb :edge_json,   default: {}
      t.jsonb :hole_json,   default: {}
      t.jsonb :sqhole_json, default: {}

      # 監査系
      t.timestamps precision: 6, null: false
      t.boolean  :deleted_flag, null: false, default: false
      t.datetime :deleted_at,   precision: 6
      t.bigint   :deleted_by_id
      t.bigint   :created_by_id
      t.bigint   :updated_by_id
    end

    # 監査系インデックス
    add_index :board_parts, :created_by_id
    add_index :board_parts, :updated_by_id
    add_index :board_parts, :deleted_by_id

    # 外部キー（コード列は参照先の主キー code に合わせる）
    add_foreign_key :board_parts, :m_materials,      column: :material_code,     primary_key: :code
    add_foreign_key :board_parts, :m_paint_types,    column: :paint_type_code,   primary_key: :code
    add_foreign_key :board_parts, :m_paint_colors,   column: :paint_color_code,  primary_key: :code
    add_foreign_key :board_parts, :m_paint_finishes, column: :paint_finish_code, primary_key: :code
    add_foreign_key :board_parts, :m_paint_glosses,  column: :paint_gloss_code,  primary_key: :code

    add_foreign_key :board_parts, :accounts, column: :created_by_id
    add_foreign_key :board_parts, :accounts, column: :updated_by_id
    add_foreign_key :board_parts, :accounts, column: :deleted_by_id
  end

  def down
    drop_table :board_parts
  end
end
