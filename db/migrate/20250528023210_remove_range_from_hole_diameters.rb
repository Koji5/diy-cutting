# db/migrate/XXXXXXXXXX_removeRangeFromHoleDiameters.rb
class RemoveRangeFromHoleDiameters < ActiveRecord::Migration[8.0]
  def change
    change_table :m_hole_diameters do |t|
      t.remove :min_mm, :max_mm
    end
  end
end