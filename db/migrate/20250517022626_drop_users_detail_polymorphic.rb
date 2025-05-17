# db/migrate/xxxxx_drop_users_detail_polymorphic.rb
class DropUsersDetailPolymorphic < ActiveRecord::Migration[7.1]
  def up
    # 1. 関連インデックスと CHECK 制約を先に外す
    remove_index :users, name: "index_users_on_detail_type_and_detail_id"
    execute <<~SQL
      ALTER TABLE users
        DROP CONSTRAINT IF EXISTS users_detail_type_value,
        DROP CONSTRAINT IF EXISTS users_role_detail_type_consistency;
    SQL

    # 2. カラムを削除
    remove_column :users, :detail_type, :string,  limit: 20, null: false
    remove_column :users, :detail_id,   :bigint,              null: false
  end

  def down
    add_column :users, :detail_type, :string, limit: 20, null: false
    add_column :users, :detail_id,   :bigint,              null: false
    add_index  :users, %i[detail_type detail_id]
    execute <<~SQL
      ALTER TABLE users
        ADD CONSTRAINT users_detail_type_value
          CHECK (detail_type IN ('MemberDetail','VendorDetail','AdminDetail','AffiliateDetail')),
        ADD CONSTRAINT users_role_detail_type_consistency
          CHECK (
            (role = 0 AND detail_type = 'MemberDetail')    OR
            (role = 1 AND detail_type = 'VendorDetail')    OR
            (role = 2 AND detail_type = 'AdminDetail')     OR
            (role = 3 AND detail_type = 'AffiliateDetail')
          );
    SQL
  end
end
