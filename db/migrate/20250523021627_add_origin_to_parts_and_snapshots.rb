class AddOriginToPartsAndSnapshots < ActiveRecord::Migration[8.0]
  def change
    %i[parts part_snapshots].each do |tbl|
      change_table tbl, bulk: true do |t|
        t.bigint :origin_snapshot_id
        t.bigint :origin_owner_id
        t.index  :origin_snapshot_id
      end
    end
  end
end