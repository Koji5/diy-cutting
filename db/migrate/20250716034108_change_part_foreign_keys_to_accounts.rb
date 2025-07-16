class ChangePartForeignKeysToAccounts < ActiveRecord::Migration[8.0]
  def change
    # 外部キー削除
    remove_foreign_key :parts, column: :user_id

    # インデックス削除
    remove_index :parts, column: :user_id

    # カラム名変更
    rename_column :parts, :user_id, :account_id

    # インデックス再作成
    add_index :parts, :account_id

    # 外部キー再設定（accounts への参照に変更）
    add_foreign_key :parts, :accounts, column: :account_id
    # 外部キーを users → accounts に変更
    remove_foreign_key :parts, column: :created_by_id
    add_foreign_key :parts, :accounts, column: :created_by_id

    remove_foreign_key :parts, column: :updated_by_id
    add_foreign_key :parts, :accounts, column: :updated_by_id

    remove_foreign_key :parts, column: :deleted_by_id
    add_foreign_key :parts, :accounts, column: :deleted_by_id

    remove_foreign_key :parts, column: :origin_owner_id
    add_foreign_key :parts, :accounts, column: :origin_owner_id

    rename_column :parts, :name, :tmp_name
    rename_column :parts, :tmp_name, :name
  end
end
