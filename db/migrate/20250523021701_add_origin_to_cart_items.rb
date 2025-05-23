class AddOriginToCartItems < ActiveRecord::Migration[8.0]
  def change
    change_table :cart_items, bulk: true do |t|
      t.bigint :origin_snapshot_id
      t.bigint :origin_owner_id
    end
  end
end
