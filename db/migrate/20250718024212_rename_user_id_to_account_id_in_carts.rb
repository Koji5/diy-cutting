class RenameUserIdToAccountIdInCarts < ActiveRecord::Migration[8.0]
  def change
    # 1. 外部キー制約を削除
    remove_foreign_key :carts, column: :user_id

    # 2. カラム名をリネーム
    rename_column :carts, :user_id, :account_id

    # 3. インデックス名も変更（user_id → account_id）
    #rename_index :carts, "index_carts_on_user_id", "index_carts_on_account_id"

    # 4. 新しい外部キー制約を追加
    add_foreign_key :carts, :accounts, column: :account_id

    # 5. shipping_address_id のインデックスを削除（先に削除しないとエラーになる可能性あり）
    remove_index :carts, :shipping_address_id

    # 6. shipping_address_id カラムを削除
    remove_column :carts, :shipping_address_id, :bigint
  end
end
