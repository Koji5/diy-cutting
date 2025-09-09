class CreateMHoleSurfaces < ActiveRecord::Migration[8.0]
  def change
    create_table :m_hole_surfaces, id: false do |t|
      t.string :code, null: false, primary_key: true
      t.string :name_ja, null: false
      t.string :name_en, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
