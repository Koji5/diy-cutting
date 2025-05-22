class CreateRfqParts < ActiveRecord::Migration[8.0]
  def change
    create_table :rfq_parts do |t|
      t.references :rfq,           null: false, foreign_key: true
      t.references :part_snapshot, null: false, foreign_key: true
      t.integer    :quantity,      null: false
      t.timestamps
    end
  end
end