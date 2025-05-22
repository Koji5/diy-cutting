class CreateVendorOfferItems < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_offer_items do |t|
      t.references :vendor_offer, null: false, foreign_key: true
      t.references :rfq_part,     null: false, foreign_key: true
      t.decimal    :unit_price,   precision: 18, scale: 4, null: false
      t.integer    :lead_time_days
      t.text       :note

      # 監査系7列
      t.timestamps                 null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.references :created_by
      t.references :updated_by
      t.boolean    :deleted_flag, null: false, default: false
      t.datetime   :deleted_at
      t.references :deleted_by
    end

    add_index :vendor_offer_items,
              %i[vendor_offer_id rfq_part_id],
              unique: true,
              name: :uniq_offer_item
  end
end
