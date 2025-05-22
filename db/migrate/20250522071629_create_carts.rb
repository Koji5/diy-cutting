class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :name,  null: false, limit: 50
      t.integer :status, null: false, default: 0  # draft / checked_out
      t.references :shipping_address             # member_shipping_addresses
      t.timestamps
    end
  end
end