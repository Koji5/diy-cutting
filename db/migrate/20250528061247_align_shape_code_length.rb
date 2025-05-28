# db/migrate/XXXXXXXXXX_alignShapeCodeLength.rb
class AlignShapeCodeLength < ActiveRecord::Migration[8.0]
  def change
    change_column :parts, :shape_code, :string, limit: 10
    # FK (parts.shape_code → m_shapes.code) は型長一致なのでそのまま生きます
  end
end
