class RecreateNameColumnInParts < ActiveRecord::Migration[8.0]
  def up
    # 一時カラムを追加し、データを退避
    add_column :parts, :name_tmp, :string, limit: 50
    execute "UPDATE parts SET name_tmp = \"name\""

    # PostgreSQLにあるクォート付きカラムを drop（SQL直書き）
    execute 'ALTER TABLE parts DROP COLUMN "name"'

    # クォート無しの name カラムを再作成
    add_column :parts, :name, :string, limit: 50, null: false, default: ""

    # データを戻す
    execute "UPDATE parts SET name = name_tmp"

    # 一時カラムを削除
    remove_column :parts, :name_tmp
  end

  def down
    add_column :parts, :name_old, :string, limit: 50
    execute "UPDATE parts SET name_old = name"
    remove_column :parts, :name
    add_column :parts, :name, :string, limit: 50, null: false, default: ""
    execute "UPDATE parts SET name = name_old"
    remove_column :parts, :name_old
  end
end
