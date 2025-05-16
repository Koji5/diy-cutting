class ChangePostalNameToText < ActiveRecord::Migration[8.0]
  def change
    change_column :m_postal_codes, :city_town_name_kanji, :text
    change_column :m_postal_codes, :town_area_name_kanji, :text
  end
end
