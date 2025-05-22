class AddTaxAndReceivedAtToVendorOffers < ActiveRecord::Migration[8.0]
  def change
    change_table :vendor_offers, bulk: true do |t|
      t.decimal    :tax_rate,   precision: 4, scale: 2, null: false, default: 10.0
      t.decimal    :tax_amount, precision: 18, scale: 4, null: false, default: 0
      t.datetime   :received_at
    end
  end
end
