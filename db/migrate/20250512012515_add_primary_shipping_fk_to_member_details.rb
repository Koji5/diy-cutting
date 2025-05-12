class AddPrimaryShippingFkToMemberDetails < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :member_details, :member_shipping_addresses,
                    column: :primary_shipping_id
  end
end