# db/migrate/20250513061725_create_stripe_payouts.rb
class CreateStripePayouts < ActiveRecord::Migration[8.0]
  def change
    # ★ここがポイント★
    # id: :string を指定すると「payout_id という string 主キー列」を
    # create_table が自動で作成してくれます
    create_table :stripe_payouts,
                 id:          :string,
                 primary_key: :payout_id do |t|

      # ここでは payout_id 列を **書かなくて OK**（自動生成）

      t.string  :stripe_account_id, null: false, limit: 255

      t.decimal :amount,        precision: 18, scale: 4,
                                null: false, default: 0
      t.date    :arrival_date,  null: false
      t.string  :status,        null: false, limit: 16
      t.string  :failure_code,  limit: 32

      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :stripe_payouts, :stripe_account_id
    add_foreign_key :stripe_payouts, :stripe_accounts,
                    column:      :stripe_account_id,
                    primary_key: :stripe_account_id
  end
end
