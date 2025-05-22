class MakeVendorOfferIdNotNullOnOrders < ActiveRecord::Migration[8.0]
def up
  null_count = execute("SELECT COUNT(*) FROM orders WHERE vendor_offer_id IS NULL").first["count"].to_i
  raise "NULL rows exist" if null_count > 0

  change_column_null :orders, :vendor_offer_id, false
end

  def down
    change_column_null :orders, :vendor_offer_id, true
  end
end
