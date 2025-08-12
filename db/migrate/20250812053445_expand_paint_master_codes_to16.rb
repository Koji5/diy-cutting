# db/migrate/XXXXXXXXXXXXXX_expand_paint_master_codes_to_16.rb
class ExpandPaintMasterCodesTo16 < ActiveRecord::Migration[8.0]
  def up
    change_column :m_paint_types,   :code, :string, limit: 16
    change_column :m_paint_colors,  :code, :string, limit: 16
    change_column :m_paint_glosses, :code, :string, limit: 16
    change_column :m_paint_finishes,:code, :string, limit: 16
    change_column :board_parts, :paint_type_code,   :string, limit: 16
    change_column :board_parts, :paint_color_code,  :string, limit: 16
    change_column :board_parts, :paint_finish_code, :string, limit: 16
    change_column :board_parts, :paint_gloss_code,  :string, limit: 16
      end

  def down
    change_column :m_paint_types,   :code, :string, limit: 10
    change_column :m_paint_colors,  :code, :string, limit: 6
    change_column :m_paint_glosses, :code, :string, limit: 6
    change_column :m_paint_finishes,:code, :string, limit: 6
  end
end
