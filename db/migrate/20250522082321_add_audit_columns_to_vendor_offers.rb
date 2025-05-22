class AddAuditColumnsToVendorOffers < ActiveRecord::Migration[8.0]
  def change
    change_table :vendor_offers, bulk: true do |t|
      t.references :created_by, foreign_key: { to_table: :users }
      t.references :updated_by, foreign_key: { to_table: :users }
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by, foreign_key: { to_table: :users }
      # created_at / updated_at は既に存在するはず
    end
  end
end
