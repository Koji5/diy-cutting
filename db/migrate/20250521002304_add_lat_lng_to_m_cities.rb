# frozen_string_literal: true

class AddLatLngToMCities < ActiveRecord::Migration[8.0]   # ★ 8.0 に統一
  # PostGIS を使わず中心点だけ欲しいため
  # decimal(9,6) ≒ ±90.000000 / ±180.000000 を十分カバー
  def up
    add_column :m_cities, :latitude,  :decimal, precision: 9, scale: 6, null: true
    add_column :m_cities, :longitude, :decimal, precision: 9, scale: 6, null: true
  end

  def down
    remove_column :m_cities, :latitude,  :decimal
    remove_column :m_cities, :longitude, :decimal
  end
end
