# db/migrate/XXXXXXXXXX_create_quote_request_items.rb
class CreateQuoteRequestItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quote_request_items do |t|
      t.bigint  :quote_request_id, null: false
      t.bigint  :quote_item_id,    null: false

      t.decimal :unit_price, precision: 18, scale: 4,
                             null: false, default: 0
      t.decimal :amount,     precision: 18, scale: 4,
                             null: false, default: 0

      t.text    :memo

      # ── メタ列 ──────────────────────────
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps  default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── インデックス & UNIQUE ───────────────
    add_index :quote_request_items, :quote_request_id
    add_index :quote_request_items, :quote_item_id
    add_index :quote_request_items,
              [:quote_request_id, :quote_item_id],
              unique: true, name: :uq_quote_request_item

    # ── 外部キー ──────────────────────────
    add_foreign_key :quote_request_items, :quote_requests
    add_foreign_key :quote_request_items, :quote_items

    # ── CHECK ─────────────────────────────
    execute <<~SQL
      ALTER TABLE quote_request_items
        ADD CONSTRAINT chk_amount_non_negative
        CHECK (amount >= 0);
    SQL
  end
end
