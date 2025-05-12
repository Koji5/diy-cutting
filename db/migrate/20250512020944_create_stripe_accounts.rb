class CreateStripeAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_accounts,
                 id: false,                  # bigint id を無効化
                 primary_key: :user_id do |t|  # PK を user_id に

      t.bigint  :user_id,             null: false               # PK + FK
      t.string  :stripe_account_id,   null: false, limit: 255
      t.boolean :charges_enabled,     null: false, default: false
      t.boolean :payouts_enabled,     null: false, default: false

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ------- インデックス -------
    add_index :stripe_accounts, :stripe_account_id
    add_foreign_key :stripe_accounts, :users, column: :user_id
  end
end
