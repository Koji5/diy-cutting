class AddUniqueIndexVendorOfferOnRfqVendor < ActiveRecord::Migration[8.0]
  def change
    # 同じ RFQ に対して同じ vendor が「有効な見積」を 1 つだけ登録できる
    add_index :vendor_offers,
              %i[rfq_id vendor_id],
              unique: true,
              where: "deleted_flag = false",
              name: :uniq_vendor_offer_per_rfq
  end
end
