# db/seeds/local/30_postal_codes.rb
# |    idx | 意味                     | 典型値             |
# | -----: | ---------------------- | --------------- |
# |  **0** | 全国地方公共団体コード（5桁）        | `01100`         |
# |      1 | 旧郵便番号（3桁）              | `060`           |
# |  **2** | 郵便番号（7桁）               | `0600000`       |
# |      3 | 都道府県名カナ                | `ﾎｯｶｲﾄﾞｳ`       |
# |  **4** | 市区町村名カナ                | `ｻｯﾎﾟﾛｼ`        |
# |  **5** | 町域名カナ                  | `ｷﾀｺﾞｼﾞｮｳﾆｼ`    |
# |      6 | 都道府県名漢字                | `北海道`           |
# |  **7** | 市区町村名漢字                | `札幌市中央区`        |
# |  **8** | 町域名漢字                  | `北五条西`          |
# |  **9** | 一町域が二以上の郵便番号を持つ場合の表示   | `0`/`1`         |
# | **10** | 小字毎に番地が起番されている町域の表示    | `0`/`1`         |
# | **11** | 丁目を有する町域の場合の表示         | `0`/`1`         |
# | **12** | 一つの郵便番号で二以上の町域を表す場合の表示 | `0`/`1`         |
# |     13 | 更新確認                   | `0`〜`5`（`2`=廃止） |
# |     14 | 変更理由                   | `0`〜`5`         |

require "csv"
path = Rails.root.join("db/seeds/local/utf_all.csv")
now  = Time.current

rows  = []
seen  = {}

CSV.foreach(path, encoding: "UTF-8") do |row|   # ← headers: false
  next if row.compact.empty?                    # 空行スキップ

  zip      = row[2]
  citycode = row[0][0,5]                        # 5桁
  key      = [zip, row[8]]                      # 郵便番号 + 町域名

  next if seen[key]            # 同一行 1 回だけ
  seen[key] = true

  rows << {
    postal_code:          zip,
    city_code:            citycode,
    city_town_name_kanji: row[7],
    town_area_name_kanji: row[8].presence,
    multi_town_flag:      row[9]  == "1",
    koaza_banchi_flag:    row[10] == "1",
    chome_flag:           row[11] == "1",
    multi_aza_flag:       row[12] == "1",
    deleted_flag:         row[13] == "2",
    deleted_at:           (row[13] == "2" ? now : nil),
    created_at:           now,
    updated_at:           now
  }
end

# 1. UPSERT 追加・更新
MPostalCode.upsert_all(rows,
  unique_by: :idx_postal_code_area_unique)

# 2. 今回 CSV に存在しなかった行をまとめて論理削除
MPostalCode
  .where.not(id: MPostalCode.where(updated_at: now.all_day))
  .where(deleted_flag: false)
  .update_all(deleted_flag: true, deleted_at: now)

puts "✓ m_postal_codes => #{rows.size} rows upserted"
