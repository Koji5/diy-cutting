# db/migrate/20250519123456_drop_stripe_account_id_from_vendor_and_affiliate_details.rb
class DropStripeAccountIdFromVendorAndAffiliateDetails < ActiveRecord::Migration[8.0]
  def change
    # ---------- vendor_details ----------
    remove_foreign_key :vendor_details, column: :stripe_account_id
    remove_index       :vendor_details, :stripe_account_id
    remove_column      :vendor_details, :stripe_account_id, :string

    # ---------- affiliate_details ----------
    remove_foreign_key :affiliate_details, column: :stripe_account_id
    remove_index       :affiliate_details, :stripe_account_id
    remove_column      :affiliate_details, :stripe_account_id, :string
  end
end
