class ChangePrefCodeLengthInVendorServicePrefectures < ActiveRecord::Migration[8.0]
  def up
    change_column :vendor_service_prefectures, :prefecture_code,
                  :string, limit: 2
  end
end
