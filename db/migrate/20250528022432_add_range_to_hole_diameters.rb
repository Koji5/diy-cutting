# db/migrate/XXXXXXXXXX_addRangeToHoleDiameters.rb
class AddRangeToHoleDiameters < ActiveRecord::Migration[8.0]
  def change
    change_table :m_hole_diameters do |t|
      t.numeric  :min_mm, precision: 8, scale: 2, null: true
      t.numeric  :max_mm, precision: 8, scale: 2, null: true
    end
  end
end
