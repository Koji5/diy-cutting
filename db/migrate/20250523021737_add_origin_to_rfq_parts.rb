class AddOriginToRfqParts < ActiveRecord::Migration[8.0]
  def change
    change_table :rfq_parts, bulk: true do |t|
      t.bigint :origin_snapshot_id, null: false
      t.bigint :origin_owner_id,    null: false
    end

    add_index :rfq_parts, :origin_owner_id
  end
end
