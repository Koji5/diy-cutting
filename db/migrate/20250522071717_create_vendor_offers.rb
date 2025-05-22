class CreateVendorOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_offers do |t|
      t.references :rfq,     null: false, foreign_key: true
      t.references :vendor,  null: false, foreign_key: { to_table: :users }
      t.integer    :status,  null: false, default: 0   # pending / selected / rejected
      t.decimal    :total_price, precision: 18, scale: 4, default: 0
      t.timestamps
    end
  end
end