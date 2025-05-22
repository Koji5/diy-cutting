class CreatePartSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :part_snapshots do |t|
      t.references :part, null: false, foreign_key: true
      t.string  :checksum, null: false
      t.timestamps
    end
    add_index :part_snapshots, :checksum
  end
end
