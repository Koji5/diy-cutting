class AdjustUsersTableForDevise < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      # === Devise用に変更・追加 ===
      t.change_default :email, from: nil, to: ""
      t.change_null :email, false

      t.change_default :encrypted_password, from: nil, to: ""
      t.change_null :encrypted_password, false

      t.change :sign_in_count, :integer, default: 0, null: false
      t.change :failed_attempts, :integer, default: 0, null: false

      # === Deviseと無関係なものを削除 ===
      t.remove :password_changed_at, :password_expires_at
      t.remove :created_by_id, :updated_by_id, :deleted_by_id
      t.remove :deleted_flag, :deleted_at
      t.remove :public_uid

    end

    # === Devise用のインデックス追加（すでにあればスキップ） ===
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :unlock_token, unique: true unless index_exists?(:users, :unlock_token)
  end
end
