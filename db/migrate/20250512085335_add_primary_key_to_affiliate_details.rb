class AddPrimaryKeyToAffiliateDetails < ActiveRecord::Migration[8.0]
  def change
    # id 列が存在する場合は削除（id: false 指定なら無いはず）
    remove_column :affiliate_details, :id, :bigint if column_exists?(:affiliate_details, :id)

    # user_id を主キーに
    execute "ALTER TABLE affiliate_details ADD PRIMARY KEY (user_id);"
  end
end