# db/migrate/XXXXXXXXXXXX_drop_quote_tables_and_prepare_orders.rb
class DropQuoteTablesAndPrepareOrders < ActiveRecord::Migration[8.0]
  def up
    # ---------------------------
    # 1. orders 側の外部キーを外す
    # ---------------------------
    remove_foreign_key :orders, :quotes         if foreign_key_exists?(:orders, :quotes)
    remove_foreign_key :orders, :quote_requests if foreign_key_exists?(:orders, :quote_requests)

    # ---------------------------
    # 2. orders の不要カラムを削除
    #    ※ shipping_address_id は後ステップで入れ替えるので残す
    # ---------------------------
    if column_exists?(:orders, :quote_id)
      remove_column :orders, :quote_id, :bigint
    end
    if column_exists?(:orders, :quote_request_id)
      remove_column :orders, :quote_request_id, :bigint
    end

    # ---------------------------
    # 3. 依存関係の深い順に旧テーブルを DROP
    # ---------------------------
    drop_table :quote_request_items, force: :cascade if table_exists?(:quote_request_items)
    drop_table :quote_requests,       force: :cascade if table_exists?(:quote_requests)
    drop_table :quote_items,          force: :cascade if table_exists?(:quote_items)
    drop_table :quotes,               force: :cascade if table_exists?(:quotes)
  end

  # down は “戻さない” 方針。どうしても復旧が必要ならダンプからリストアしてください
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
