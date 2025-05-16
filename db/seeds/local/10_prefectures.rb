# frozen_string_literal: true
# 都道府県マスタ（JIS X 0401）――ローカル専用シード
#
#   rails db:seed RAILS_ENV=development
#
PREFECTURES = [
  # code,  name_ja,    name_en,     kana
  %w[01 北海道 Hokkaido ホッカイドウ],
  %w[02 青森県 Aomori アオモリケン],
  %w[03 岩手県 Iwate イワテケン],
  %w[04 宮城県 Miyagi ミヤギケン],
  %w[05 秋田県 Akita アキタケン],
  %w[06 山形県 Yamagata ヤマガタケン],
  %w[07 福島県 Fukushima フクシマケン],
  %w[08 茨城県 Ibaraki イバラキケン],
  %w[09 栃木県 Tochigi トチギケン],
  %w[10 群馬県 Gunma グンマケン],
  %w[11 埼玉県 Saitama サイタマケン],
  %w[12 千葉県 Chiba チバケン],
  %w[13 東京都 Tokyo トウキョウト],
  %w[14 神奈川県 Kanagawa カナガワケン],
  %w[15 新潟県 Niigata ニイガタケン],
  %w[16 富山県 Toyama トヤマケン],
  %w[17 石川県 Ishikawa イシカワケン],
  %w[18 福井県 Fukui フクイケン],
  %w[19 山梨県 Yamanashi ヤマナシケン],
  %w[20 長野県 Nagano ナガノケン],
  %w[21 岐阜県 Gifu ギフケン],
  %w[22 静岡県 Shizuoka シズオカケン],
  %w[23 愛知県 Aichi アイチケン],
  %w[24 三重県 Mie ミエケン],
  %w[25 滋賀県 Shiga シガケン],
  %w[26 京都府 Kyoto キョウトフ],
  %w[27 大阪府 Osaka オオサカフ],
  %w[28 兵庫県 Hyogo ヒョウゴケン],
  %w[29 奈良県 Nara ナラケン],
  %w[30 和歌山県 Wakayama ワカヤマケン],
  %w[31 鳥取県 Tottori トットリケン],
  %w[32 島根県 Shimane シマネケン],
  %w[33 岡山県 Okayama オカヤマケン],
  %w[34 広島県 Hiroshima ヒロシマケン],
  %w[35 山口県 Yamaguchi ヤマグチケン],
  %w[36 徳島県 Tokushima トクシマケン],
  %w[37 香川県 Kagawa カガワケン],
  %w[38 愛媛県 Ehime エヒメケン],
  %w[39 高知県 Kochi コウチケン],
  %w[40 福岡県 Fukuoka フクオカケン],
  %w[41 佐賀県 Saga サガケン],
  %w[42 長崎県 Nagasaki ナガサキケン],
  %w[43 熊本県 Kumamoto クマモトケン],
  %w[44 大分県 Oita オオイタケン],
  %w[45 宮崎県 Miyazaki ミヤザキケン],
  %w[46 鹿児島県 Kagoshima カゴシマケン],
  %w[47 沖縄県 Okinawa オキナワケン]
].freeze

rows = PREFECTURES.map do |code, name_ja, name_en, kana|
  { code:, name_ja:, name_en:, kana:,
    created_at: Time.current, updated_at: Time.current }
end

MPrefecture.upsert_all(rows, unique_by: :code)  # ← idempotent
puts "✓ m_prefectures => #{rows.size} rows upserted"
