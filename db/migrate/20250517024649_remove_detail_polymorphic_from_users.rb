class RemoveDetailPolymorphicFromUsers < ActiveRecord::Migration[8.0]
  def change
    # ↓ 先に関連 Index を安全に外す
    remove_index :users,
                 name: :index_users_on_detail_type_and_detail_id,
                 if_exists: true

    # ↓ 列を存在チェック付きで削除
    remove_column :users, :detail_type, :string, limit: 20, if_exists: true
    remove_column :users, :detail_id,   :bigint,            if_exists: true
  end
end