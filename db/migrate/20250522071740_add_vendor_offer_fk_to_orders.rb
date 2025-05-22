class AddVendorOfferFkToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :vendor_offer, foreign_key: true
    # shipping_address_id は後で transaction_shipping_addresses に貼り替える予定
  end
end