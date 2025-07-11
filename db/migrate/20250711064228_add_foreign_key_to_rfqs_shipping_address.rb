class AddForeignKeyToRfqsShippingAddress < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :rfqs, :member_shipping_addresses, column: :shipping_address_id
  end
end
