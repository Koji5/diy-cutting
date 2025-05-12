class CreateUserAuthorities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_authorities do |t|          # bigint PK “id” はデフォルト

      # ────── 外部キー ──────
      t.references :user,               null: false, foreign_key: true, index: true
      t.string     :authority_code,     null: false, limit: 30          # m_authorities.code FK

      # ────── 業務カラム ──────
      t.integer    :grant_state,        null: false, limit: 2, default: 1  # 0=deny 1=grant
      t.datetime   :valid_from
      t.datetime   :valid_to

      # ────── 作成日時 ──────
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ────── 制約・インデックス ──────
    add_index :user_authorities, [:user_id, :authority_code], unique: true
    add_foreign_key :user_authorities, :m_authorities, column: :authority_code, primary_key: :code

    # grant_state 値チェック
    execute <<~SQL
      ALTER TABLE user_authorities
        ADD CONSTRAINT user_authorities_grant_state_chk
          CHECK (grant_state IN (0, 1));
    SQL
  end
end