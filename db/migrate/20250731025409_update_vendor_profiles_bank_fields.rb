class UpdateVendorProfilesBankFields < ActiveRecord::Migration[8.0]
  def change
    change_table :vendor_profiles, bulk: true do |t|
      t.string :office_name,       limit: 100
      t.string :office_name_kana,  limit: 100
      t.string :bank_code,         limit: 4
      t.string :branch_code,       limit: 3
      t.remove :bank_name
    end
  end
end
