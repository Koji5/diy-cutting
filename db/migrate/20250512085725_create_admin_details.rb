class CreateAdminDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_details, id: false do |t|
      t.bigint :user_id, null: false              # ← 明示的に列を作る

      t.string :nickname,  limit: 50
      t.string :icon_url,  limit: 255
      t.string :department, limit: 100

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # 主キーを後付けで付与
    execute "ALTER TABLE admin_details ADD PRIMARY KEY (user_id);"

    # インデックス
    add_index :admin_details, :nickname, unique: true
    add_foreign_key :admin_details, :users,
                    column: :user_id, primary_key: :id
  end
end
