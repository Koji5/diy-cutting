# frozen_string_literal: true
# 実行: bin/rails runner scripts/import_city_centroids.rb

require "json"
require "rgeo"
require "rgeo/geo_json"

# 1) GeoJSON 読み込み
file = File.read("public/japan_munis_simplified.geojson")

# 2) ★ GEOS バックエンドのファクトリを用意
factory = RGeo::Geos.factory(srid: 4326)              # ← ここ重要

# 3) GeoJSON → FeatureCollection をデコード
fc = RGeo::GeoJSON.decode(JSON.parse(file), json_parser: :json,
                          geo_factory: factory)

# 4) m_cities を一括更新
ActiveRecord::Base.transaction do
  fc.each do |feature|
    code = feature.properties["city_code"] ||
           feature.properties["N03_007"]   ||    # N03 の列名
           feature.properties["code"]
    next unless code && feature.geometry

    centroid = feature.geometry.centroid           # もう例外にならない
    MCity.where(code: code).update_all(
      latitude:  centroid.y.round(6),              # lat  = Y（緯度）
      longitude: centroid.x.round(6)               # lon  = X（経度）
    )
  end
end

puts "✅ m_cities lat/lng updated"
