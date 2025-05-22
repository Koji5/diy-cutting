class CreateTransactionShippingAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :transaction_shipping_addresses do |t|
      t.string :recipient_name,  null: false
      t.string :postal_code,     null: false, limit: 8
      t.string :prefecture_code, null: false, limit: 2
      t.string :city_code,       null: false, limit: 5
      t.string :address_line,    null: false
      t.timestamps
    end
  end
end