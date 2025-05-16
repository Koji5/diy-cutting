# frozen_string_literal: true
# 市区町村マスタ登録（総務省 Excel を UTF-8 CSV で保存したファイル用）
# CSV を db/seeds/local/00_cities.csv に置く
require "csv"
csv_path = Rails.root.join("db/seeds/local/00_cities.csv")

rows  = []
seen  = {}                       # 6桁コード -> true

CSV.foreach(csv_path, headers: true, encoding: "UTF-8") do |r|
  next if r["市区町村名（漢字）"].blank?    # 市区町村名が空行＝都道府県行

  #code6 = r["団体コード"].strip
  code5 = r["団体コード"].strip[0,5]
  #next if seen[code6]                     # 重複行はスキップ
  #seen[code6] = true
  next if seen[code5]                     # 重複行はスキップ
  seen[code5] = true

  rows << {
    code:            code5,               # ← 6 桁
    prefecture_code: code5[0, 2],
    name_ja:         r["市区町村名（漢字）"].strip,
    name_kana:       r["市区町村名（カナ）"].to_s.strip,
    created_at:      Time.current,
    updated_at:      Time.current
  }
end

MCity.upsert_all(rows, unique_by: :code)
puts "✓ m_cities => #{rows.size} rows upserted"
