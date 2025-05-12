class AddPrimaryKeyToVendorDetailsUserId < ActiveRecord::Migration[8.0]
  def change
    # id 列が残っていれば削除（無ければスキップ）
    remove_column :vendor_details, :id, :bigint if column_exists?(:vendor_details, :id)

    # user_id を主キーに
    execute "ALTER TABLE vendor_details ADD PRIMARY KEY (user_id);"
  end
end