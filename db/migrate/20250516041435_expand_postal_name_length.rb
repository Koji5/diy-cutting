class ExpandPostalNameLength < ActiveRecord::Migration[8.0]
  def change
    change_column :m_postal_codes, :city_town_name_kanji, :string, limit: 255
    change_column :m_postal_codes, :town_area_name_kanji, :string, limit: 255
  end
end
