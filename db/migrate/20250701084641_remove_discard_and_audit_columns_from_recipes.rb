class RemoveDiscardAndAuditColumnsFromRecipes < ActiveRecord::Migration[8.0]
  def up
    # 論理削除用
    remove_column :recipes, :deleted_flag, :boolean
    remove_column :recipes, :deleted_at,  :datetime

    # 操作ユーザー追跡用
    remove_reference :recipes, :deleted_by, foreign_key: { to_table: :users }
    remove_reference :recipes, :created_by, foreign_key: { to_table: :users }
    remove_reference :recipes, :updated_by, foreign_key: { to_table: :users }
  end

  def down
    # ロールバック用に元へ戻せるよう定義
    add_column :recipes, :deleted_flag, :boolean, default: false, null: false
    add_column :recipes, :deleted_at,  :datetime

    add_reference :recipes, :deleted_by, foreign_key: { to_table: :users }
    add_reference :recipes, :created_by, foreign_key: { to_table: :users }
    add_reference :recipes, :updated_by, foreign_key: { to_table: :users }
  end
end
