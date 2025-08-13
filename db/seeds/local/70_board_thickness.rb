thicknesses = [3.0, 5.5, 9.0, 12.0, 15.0, 18.0, 21.0, 24.0, 30.0]

rows = thicknesses.map do |t|
  code = "mm#{(t * 10).round.to_s.rjust(3, "0")}"   # 3.0=>mm030, 5.5=>mm055 など
  {
    code:         code,
    thickness_mm: t,
    name_ja:      "#{format('%.1f', t)}ミリメートル",
    name_en:      "#{format('%.1f', t)}mm",
    created_at:   Time.current,
    updated_at:   Time.current
  }
end

# 主キー(code)で upsert（存在すれば更新、無ければ作成）
MBoardThickness.upsert_all(rows)
