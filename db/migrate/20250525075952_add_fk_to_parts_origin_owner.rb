class AddFkToPartsOriginOwner < ActiveRecord::Migration[8.0]
  def change
    # 既に index がある場合は add_foreign_key だけで OK
    add_foreign_key :parts, :users, column: :origin_owner_id

    # 無ければ index も
    # add_index :parts, :origin_owner_id
  end
end
