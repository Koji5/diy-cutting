# db/migrate/XXXXXXXXXXXXXX_add_department_to_member_shipping_addresses.rb
class AddDepartmentToMemberShippingAddresses < ActiveRecord::Migration[8.0]
  def change
    add_column :member_shipping_addresses, :department, :string, limit: 100
  end
end
