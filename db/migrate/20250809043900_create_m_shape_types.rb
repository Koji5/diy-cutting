class CreateMShapeTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :m_shape_types, id: false do |t|
      t.string  :code, limit: 12, null: false, primary_key: true
      t.string  :name_ja, limit: 10, null: false
      t.string  :name_en, limit: 20, null: false
      t.string  :kana,    limit: 20, null: false

      t.bigint  :created_by_id
      t.bigint  :updated_by_id
      t.boolean :deleted_flag, null: false, default: false
      t.timestamp :deleted_at
      t.bigint  :deleted_by_id

      t.timestamps
    end

    add_foreign_key :m_shape_types, :accounts, column: :created_by_id
    add_foreign_key :m_shape_types, :accounts, column: :updated_by_id
    add_foreign_key :m_shape_types, :accounts, column: :deleted_by_id

    add_index :m_shape_types, :code, unique: true
    add_index :m_shape_types, :name_ja, unique: true
    add_index :m_shape_types, :created_by_id
    add_index :m_shape_types, :updated_by_id
    add_index :m_shape_types, :deleted_by_id
  end
end
