class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|                       # bigint PK “id” はデフォルトで付与
      # ────────────── 固有カラム ──────────────
      t.string  :public_uid,         limit: 32,  null: false
      t.string  :email,                             null: false
      t.string  :encrypted_password,                null: false

      t.integer :role,               limit: 2,   null: false   # smallint 相当
      t.string  :detail_type,        limit: 20,  null: false
      t.bigint  :detail_id,                         null: false

      t.integer :login_failed_count,               null: false, default: 0
      t.datetime :last_login_failed_at

      t.datetime :password_changed_at,              null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :password_expires_at

      # ────────────── 作成・更新・削除メタ ──────────────
      t.references :created_by, foreign_key: { to_table: :users }, index: true
      t.references :updated_by, foreign_key: { to_table: :users }, index: true
      t.boolean    :deleted_flag,                  null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }, index: true

      # created_at / updated_at ─ DB 側で CURRENT_TIMESTAMP を付与
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ────────────── インデックス / 一意制約 ──────────────
    add_index :users, :public_uid, unique: true
    add_index :users, :email,      unique: true
    add_index :users, %i[detail_type detail_id]

    # ────────────── CHECK 制約 ──────────────
    execute <<~SQL
      ALTER TABLE users
      ADD CONSTRAINT users_role_value
        CHECK (role IN (0,1,2,3));

      ALTER TABLE users
      ADD CONSTRAINT users_detail_type_value
        CHECK (detail_type IN ('MemberDetail','VendorDetail',
                               'AdminDetail','AffiliateDetail'));

      ALTER TABLE users
      ADD CONSTRAINT users_role_detail_type_consistency
        CHECK (
          (role = 0 AND detail_type = 'MemberDetail')   OR
          (role = 1 AND detail_type = 'VendorDetail')   OR
          (role = 2 AND detail_type = 'AdminDetail')    OR
          (role = 3 AND detail_type = 'AffiliateDetail')
        );
    SQL
  end
end
