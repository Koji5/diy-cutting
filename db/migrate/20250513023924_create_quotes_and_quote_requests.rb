# db/migrate/XXXXXXXXXX_create_quotes_and_quote_requests.rb
class CreateQuotesAndQuoteRequests < ActiveRecord::Migration[8.0]
  def change
    # ───────── quotes ─────────
    create_table :quotes do |t|
      t.bigint  :user_id,            null: false
      t.integer :status,             null: false, limit: 2, default: 0
      t.bigint  :shipping_address_id, null: false
      t.string  :ship_prefecture_code, limit: 2, null: false, default: ''
      t.string  :ship_city_code,      limit: 5
      t.text    :global_requirements
      t.date    :deadline
      t.text    :remarks

      t.bigint  :accepted_request_id                       # ← FK 後付け
      t.datetime :accepted_at
      t.decimal :total_estimate, precision: 18, scale: 4, null: false, default: 0

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :quotes, :user_id
    add_index :quotes, :shipping_address_id
    add_index :quotes, :accepted_request_id, unique: true

    add_foreign_key :quotes, :users, column: :user_id
    add_foreign_key :quotes, :member_shipping_addresses,
                    column: :shipping_address_id,
                    on_delete: :restrict, on_update: :cascade

    # ───────── quote_requests ─────────
    create_table :quote_requests do |t|
      t.bigint  :quote_id,  null: false
      t.bigint  :vendor_id, null: false
      t.integer :status,    null: false, limit: 2, default: 0

      t.decimal :items_subtotal, precision: 18, scale: 4, null: false, default: 0
      t.decimal :shipping_fee,  precision: 18, scale: 4, null: false, default: 0
      t.decimal :tax_rate_pct,  precision: 4,  scale: 2, null: false, default: 10.00
      t.decimal :tax_amount,    precision: 18, scale: 4, null: false, default: 0
      t.decimal :total_estimate,precision: 18, scale: 4, null: false, default: 0
      t.datetime :answered_at

      # メタ
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    add_index :quote_requests, :quote_id
    add_index :quote_requests, :vendor_id
    add_index :quote_requests, [:quote_id, :vendor_id], unique: true

    add_foreign_key :quote_requests, :quotes, column: :quote_id
    add_foreign_key :quote_requests, :users,  column: :vendor_id

    # ───────── 循環 FK（後付け）─────────
    add_foreign_key :quotes, :quote_requests,
                    column: :accepted_request_id,
                    primary_key: :id
  end
end
