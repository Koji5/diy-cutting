# db/migrate/XXXXXXXXXX_create_stripe_payments.rb
class CreateStripePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :stripe_payments do |t|
      # ───────── 参照キー ─────────
      t.references :order, null: false,
                   foreign_key: true,
                   index: { unique: true }           # 発注 1 件につき 1 レコード

      # ───────── Stripe オブジェクト ID ─────
      t.string :payment_intent_id,  null: false, limit: 255
      t.string :charge_id,          null: false, limit: 255
      t.string :transfer_id,        null: false, limit: 255
      t.string :application_fee_id, null: false, limit: 255

      # ───────── 金額情報 ─────────
      t.decimal :amount,        precision: 18, scale: 4, null: false, default: 0
      t.string  :currency,      limit: 3,                  null: false, default: 'JPY'
      t.decimal :platform_fee,  precision: 18, scale: 4, null: false, default: 0
      t.decimal :net_amount,    precision: 18, scale: 4, null: false, default: 0

      # ───────── ステータス ────────
      t.string  :status,        limit: 32, null: false

      # ───────── メタ列 ───────────
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── 一意インデックス ─────────────────────
    add_index :stripe_payments, :payment_intent_id, unique: true
  end
end
