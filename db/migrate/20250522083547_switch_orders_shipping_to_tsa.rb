# db/migrate/XXXXXXXXXX_switch_orders_shipping_to_tsa.rb
class SwitchOrdersShippingToTsa < ActiveRecord::Migration[8.0]
  def up
    # 1) 旧 FK を外す
    if foreign_key_exists?(:orders, :member_shipping_addresses)
      remove_foreign_key :orders, :member_shipping_addresses
    end

    # 2) 新 FK を貼る
    add_foreign_key :orders, :transaction_shipping_addresses,
                    column: :shipping_address_id,
                    on_delete: :restrict

    # 3) インデックスは既存のものを再利用
    #    （index_orders_on_shipping_address_id が既にあるはず）
  end

  def down
    # 差し戻す場合
    remove_foreign_key :orders, :transaction_shipping_addresses

    add_foreign_key :orders, :member_shipping_addresses,
                    column: :shipping_address_id,
                    on_delete: :restrict
  end
end
