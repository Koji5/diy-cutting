class AddCoverageScopeToVendorDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :vendor_details, :coverage_scope, :integer, null: false, default: 0
    add_index  :vendor_details, :coverage_scope
  end
end