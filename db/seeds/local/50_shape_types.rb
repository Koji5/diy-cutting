# db/seeds/local/50_shape_types.rb

# 形状種別マスタ
# 板材・角材（将来パイプ材・円材など追加予定）

records = [
  { code: "board",  name_ja: "板材",  name_en: "Board",  kana: "イタザイ" },
  { code: "lumber", name_ja: "角材",  name_en: "Lumber", kana: "カクザイ" }
]

records.each do |attrs|
  MShapeType.find_or_create_by!(code: attrs[:code]) do |record|
    record.name_ja = attrs[:name_ja]
    record.name_en = attrs[:name_en]
    record.kana    = attrs[:kana]
  end
end
