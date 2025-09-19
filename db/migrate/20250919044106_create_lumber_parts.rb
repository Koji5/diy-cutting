class CreateLumberParts < ActiveRecord::Migration[8.0]
  def change
    create_table :lumber_parts do |t|
      t.bigint  :part_id,           null: false

      t.string  :material_code,     null: false, limit: 16
      t.string  :paint_type_code,   null: false, limit: 16
      t.string  :paint_color_code,  null: true,  limit: 16
      t.string  :paint_finish_code, null: true,  limit: 16
      t.string  :paint_gloss_code,  null: true,  limit: 16

      t.string  :lumber_size_code,  null: false, limit: 16
      t.decimal :length_mm,         null: false, precision: 8, scale: 2

      t.jsonb   :side_json,   null: true,  default: {}
      t.jsonb   :hole_json,   null: true,  default: {}
      t.jsonb   :sqhole_json, null: true,  default: {}
      t.jsonb   :camera_state_json, null: true, default: {}

      t.boolean :deleted_flag, null: false, default: false
      t.datetime :deleted_at,  null: true

      t.bigint :deleted_by_id, null: true
      t.bigint :created_by_id, null: true
      t.bigint :updated_by_id, null: true

      t.timestamps null: false
    end

    # 主キー（id）は create_table デフォルトで付与

    # 🔗 外部キー
    add_foreign_key :lumber_parts, :parts, column: :part_id

    add_foreign_key :lumber_parts, :accounts, column: :created_by_id
    add_foreign_key :lumber_parts, :accounts, column: :updated_by_id
    add_foreign_key :lumber_parts, :accounts, column: :deleted_by_id

    add_foreign_key :lumber_parts, :m_materials,     column: :material_code,     primary_key: :code
    add_foreign_key :lumber_parts, :m_paint_finishes, column: :paint_finish_code, primary_key: :code
    add_foreign_key :lumber_parts, :m_paint_types,    column: :paint_type_code,   primary_key: :code
    add_foreign_key :lumber_parts, :m_paint_colors,   column: :paint_color_code,  primary_key: :code
    add_foreign_key :lumber_parts, :m_paint_glosses,  column: :paint_gloss_code,  primary_key: :code
    add_foreign_key :lumber_parts, :m_lumber_sizes,   column: :lumber_size_code,  primary_key: :code

    # 🧱 インデックス
    add_index :lumber_parts, :created_by_id, name: "index_lumber_parts_on_created_by_id"
    add_index :lumber_parts, :updated_by_id, name: "index_lumber_parts_on_updated_by_id"
    add_index :lumber_parts, :deleted_by_id, name: "index_lumber_parts_on_deleted_by_id"

    # part_id は 1:1 制約（ユニーク）
    add_index :lumber_parts, :part_id, unique: true, name: "index_lumber_parts_on_part_id"

    # よく検索しそうなコード類に任意で追加
    add_index :lumber_parts, :material_code
    add_index :lumber_parts, :lumber_size_code

    # データ保全（任意のチェック制約）
    add_check_constraint :lumber_parts, "length_mm > 0", name: "chk_lumber_parts_length_positive"
  end
end
