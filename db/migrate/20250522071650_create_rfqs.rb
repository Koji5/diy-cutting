class CreateRfqs < ActiveRecord::Migration[8.0]
  def change
    create_table :rfqs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shipping_address
      t.integer :status, null: false, default: 0   # draft / requested / closed
      t.timestamps
    end
  end
end