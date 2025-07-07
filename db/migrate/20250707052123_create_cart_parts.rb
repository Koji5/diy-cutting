class CreateCartParts < ActiveRecord::Migration[8.0]
  def change
    create_table :cart_parts do |t|
      t.references :cart, null: false, foreign_key: true, index: true
      t.references :part, null: false, foreign_key: true, index: true
      t.integer :quantity, null: false, default: 1
      t.bigint :origin_snapshot_id
      t.bigint :origin_owner_id

      t.timestamps
    end
  end
end
