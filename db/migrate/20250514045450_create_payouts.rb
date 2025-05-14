class CreatePayouts < ActiveRecord::Migration[8.0]
  def change
    create_table :payouts do |t|
      t.string   :payee_type,  null: false, limit: 20
      t.bigint   :payee_id,    null: false
      t.date     :period_from
      t.date     :period_to
      t.decimal  :gross_amount,      precision: 18, scale: 4, null: false, default: 0
      t.decimal  :commission_amount, precision: 18, scale: 4, null: false, default: 0
      t.decimal  :net_amount,        precision: 18, scale: 4, null: false, default: 0
      t.integer  :status,            null: false, default: 0, limit: 2          # smallint
      t.datetime :payout_at
      t.string   :transaction_ref,  limit: 100
      t.string   :bank_name,        limit: 100
      t.integer  :account_type,     limit: 2                                      # ordinary / checking
      t.string   :account_number,   limit: 30
      t.text     :remarks

      # meta columns
      t.boolean  :deleted_flag, null: false, default: false
      t.datetime :deleted_at
      t.bigint   :deleted_by_id
      t.bigint   :created_by_id
      t.bigint   :updated_by_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # -------------------------------------------
    # インデックス & 制約
    # -------------------------------------------
    add_index :payouts, [:payee_type, :payee_id]
    add_index :payouts, :transaction_ref, unique: true
    add_index :payouts, :created_by_id
    add_index :payouts, :updated_by_id
    add_index :payouts, :deleted_by_id

    add_foreign_key :payouts, :stripe_payouts,
                    column:      :transaction_ref,
                    primary_key: :payout_id

    add_foreign_key :payouts, :users, column: :created_by_id
    add_foreign_key :payouts, :users, column: :updated_by_id
    add_foreign_key :payouts, :users, column: :deleted_by_id

    # 同じ受取先 × 期間の重複を禁止
    add_index :payouts,
              [:payee_type, :payee_id, :period_from, :period_to],
              unique: true,
              name: :uq_payouts_period

    # 受取主体タイプのホワイトリスト
    execute <<~SQL
      ALTER TABLE payouts
        ADD CONSTRAINT chk_payouts_payee_type
          CHECK (payee_type IN ('MemberDetail','VendorDetail','AdminDetail','AffiliateDetail'));
    SQL
  end
end
