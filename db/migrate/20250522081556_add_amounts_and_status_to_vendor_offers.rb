# db/migrate/XXXXXXXXXX_add_amounts_and_status_to_vendor_offers.rb
class AddAmountsAndStatusToVendorOffers < ActiveRecord::Migration[8.0]
  def change
    change_table :vendor_offers, bulk: true do |t|
      # ------- 金額カラム（precision: 18, scale: 4） -------
      unless column_exists?(:vendor_offers, :sub_total)
        t.decimal :sub_total,     precision: 18, scale: 4, null: false, default: 0
      end
      unless column_exists?(:vendor_offers, :shipping_fee)
        t.decimal :shipping_fee,  precision: 18, scale: 4, null: false, default: 0
      end
      unless column_exists?(:vendor_offers, :total_price)
        t.decimal :total_price,   precision: 18, scale: 4, null: false, default: 0
      end

      # ------- ステータス列 -------
      unless column_exists?(:vendor_offers, :status)
        t.integer :status, null: false, default: 0   # 0: pending / 1: selected / 2: rejected
      else
        change_column_default :vendor_offers, :status, 0
        change_column_null    :vendor_offers, :status, false
      end
    end

    # ------- インデックス（検索高速化） -------
    add_index :vendor_offers, :status             unless index_exists?(:vendor_offers, :status)
    add_index :vendor_offers, [:rfq_id, :status]  unless index_exists?(:vendor_offers, [:rfq_id, :status])
    add_index :vendor_offers, [:vendor_id, :status] unless index_exists?(:vendor_offers, [:vendor_id, :status])
  end
end
