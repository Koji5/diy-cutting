# db/seeds/local/60_paints.rb
# 塗装マスタ（types / colors / glosses / finishes）
# NOTE: find_or_create_by! を使うため、既存レコードは更新しません。
#       値を更新したい場合は find_or_initialize_by + assign_attributes + save! にしてください。

# --- m_paint_types ---------------------------------------------------------
[
  { code: "raw_sanded",  name_ja: "未塗装（サンダー仕上げ）", name_en: "raw_sanded" },
  { code: "oil_finish",  name_ja: "オイル仕上げ（無色）",   name_en: "oil_finish" },
  { code: "stained_oil", name_ja: "オイルステイン（着色オイル）", name_en: "stained_oil" },
  { code: "urethane",    name_ja: "ウレタン塗装（クリア／着色）", name_en: "urethane" },
  { code: "paint",       name_ja: "ペンキ仕上げ（不透明カラー）",  name_en: "paint" }
].each do |attrs|
  MPaintType.find_or_create_by!(code: attrs[:code]) do |r|
    r.name_ja = attrs[:name_ja]
    r.name_en = attrs[:name_en]
  end
end

# --- m_paint_colors --------------------------------------------------------
[
  { code: "clear",       name_ja: "透明",          name_en: "clear",
    allow_paint_types: { "urethane" => true, "oil_finish" => true } },

  { code: "natural",     name_ja: "ナチュラル",    name_en: "natural",
    allow_paint_types: { "stained_oil" => true, "urethane" => true, "paint" => true } },

  { code: "light_brown", name_ja: "ライトブラウン", name_en: "light_brown",
    allow_paint_types: { "stained_oil" => true, "urethane" => true, "paint" => true } },

  { code: "dark_brown",  name_ja: "ダークブラウン", name_en: "dark_brown",
    allow_paint_types: { "stained_oil" => true, "urethane" => true, "paint" => true } },

  { code: "black",       name_ja: "ブラック",      name_en: "black",
    allow_paint_types: { "urethane" => true, "paint" => true } },

  { code: "white",       name_ja: "ホワイト",      name_en: "white",
    allow_paint_types: { "paint" => true } },

  { code: "gray",        name_ja: "グレー",        name_en: "gray",
    allow_paint_types: { "paint" => true } }
].each do |attrs|
  MPaintColor.find_or_create_by!(code: attrs[:code]) do |r|
    r.name_ja           = attrs[:name_ja]
    r.name_en           = attrs[:name_en]
    r.allow_paint_types = attrs[:allow_paint_types]
  end
end

# --- m_paint_glosses -------------------------------------------------------
[
  { code: "matte",      name_ja: "艶なし（マット）", name_en: "matte",
    allow_paint_types: { "paint" => true } },

  { code: "semi_matte", name_ja: "3分ツヤ",          name_en: "semi_matte",
    allow_paint_types: { "urethane" => true } },

  { code: "semi_gloss", name_ja: "半ツヤ",           name_en: "semi_gloss",
    allow_paint_types: { "urethane" => true } },

  { code: "gloss",      name_ja: "ツヤあり（光沢）",  name_en: "gloss",
    allow_paint_types: { "paint" => true } }
].each do |attrs|
  MPaintGloss.find_or_create_by!(code: attrs[:code]) do |r|
    r.name_ja           = attrs[:name_ja]
    r.name_en           = attrs[:name_en]
    r.allow_paint_types = attrs[:allow_paint_types]
  end
end

# --- m_paint_finishes ------------------------------------------------------
[
  { code: "open",      name_ja: "オープン塗装", name_en: "open",
    description_ja: "木目を活かした自然仕上げ。北欧家具、ナチュラル仕上げ、素地感あり",
    allow_paint_types: { "oil_finish" => true, "stained_oil" => true } },

  { code: "semi_open", name_ja: "セミオープン塗装", name_en: "semi_open",
    description_ja: "木目がやや見える仕上げ。落ち着いたカフェ風家具、やや高級感あり",
    allow_paint_types: { "stained_oil" => true, "urethane" => true } },

  { code: "closed",    name_ja: "クローズ塗装", name_en: "closed",
    description_ja: "木目を隠すツルツル仕上げ。高級テーブル、ピアノ塗装風、木材の表情はほぼ見えない",
    allow_paint_types: { "urethane" => true, "paint" => true } }
].each do |attrs|
  MPaintFinish.find_or_create_by!(code: attrs[:code]) do |r|
    r.name_ja           = attrs[:name_ja]
    r.name_en           = attrs[:name_en]
    r.description_ja    = attrs[:description_ja]
    r.allow_paint_types = attrs[:allow_paint_types]
  end
end
