# db/migrate/XXXXXXXXXX_create_stripe_refunds.rb
class CreateStripeRefunds < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_refunds,
                 id: false,
                 primary_key: :refund_id do |t|

      t.string  :refund_id,        null: false, limit: 255   # PK
      t.string  :payment_intent_id, null: false, limit: 255

      t.decimal :amount,  precision: 18, scale: 4,
                 null: false, default: 0
      t.string  :status, limit: 16, null: false
      t.string  :reason, limit: 32, null: false

      # ──────── メタ列 ─────────
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ──────── 外部キー & インデックス ─────────
    add_index :stripe_refunds, :payment_intent_id
    add_foreign_key :stripe_refunds, :stripe_payments,
                    column:     :payment_intent_id,
                    primary_key: :payment_intent_id,
                    on_delete: :cascade
  end
end
