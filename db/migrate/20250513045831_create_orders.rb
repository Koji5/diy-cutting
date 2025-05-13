# db/migrate/XXXXXXXXXX_create_orders.rb
class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :quote,           null: false, foreign_key: true
      t.bigint     :quote_request_id                 # 後で FK を明示
      t.references :user,            null: false, foreign_key: true
      t.references :vendor,          null: false, foreign_key: { to_table: :users }
      t.references :affiliate,                       foreign_key: { to_table: :users }

      t.integer :status,             null: false, default: 0, limit: 2
      t.decimal :total_amount,       precision: 18, scale: 4,
                                     null: false, default: 0

      t.references :shipping_address, null: false,
                  foreign_key: { to_table: :member_shipping_addresses,
                                  on_update: :cascade,
                                  on_delete: :restrict }

      t.integer :shipping_method,    null: false, default: 0, limit: 2
      t.integer :shipping_size_class,                       limit: 2

      t.datetime :paid_at
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.string   :shipping_tracking_no, limit: 50

      # ── メタ列 ────────────────────────────
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }, null: false
    end

    # ── インデックス & 一意制約 ───────────────
    add_index :orders, :quote_request_id, unique: true, name: :uq_orders_quote_request
    # add_index :orders, :affiliate_id
    # affiliate_id は t.references で自動インデックス済み

    # ── 外部キー (quote_request) ───────────────
    add_foreign_key :orders,
                    :quote_requests,
                    column:     :quote_request_id,
                    on_delete:  :nullify   # 回答削除でも発注は残す
  end
end
