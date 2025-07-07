class DropCartItems < ActiveRecord::Migration[8.0]
  def change
    drop_table :cart_items
  end
end
