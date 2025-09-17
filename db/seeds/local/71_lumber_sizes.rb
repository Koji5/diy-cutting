# frozen_string_literal: true

rows = [
  # 実寸, 業界名, HC名, 特徴
  { w: 30, t: 30,  iname: nil,             hname: "角棒（小）",
    feature: "小物製作・棚受け・DIY初心者向け。軽量・扱いやすい。" },

  { w: 45, t: 45,  iname: "45角（正角材）", hname: "角材（中）または角棒（中）",
    feature: "杉・ヒノキなどの国産材で多い。住宅部材や下地材としても使われる。" },

  { w: 60, t: 60,  iname: "60角",          hname: "角材（太）または柱材",
    feature: "構造材、脚材など強度が必要な部分に。" },

  { w: 105, t: 105, iname: "105角（柱材）", hname: "柱材（太）",
    feature: "在来工法の住宅柱。DIYでは扱いづらいサイズ。" },

  { w: 38, t: 19,  iname: "SPF 1×2材",     hname: "棚受け材、小物材",
    feature: "裏桟・仕切り・装飾など軽作業向け。" },

  { w: 89, t: 19,  iname: "SPF 1×4材",     hname: "棚板、小物板材",
    feature: "棚板、すのこ、看板など薄くて軽い用途。" },

  { w: 38, t: 38,  iname: "SPF 2×2材",     hname: "角棒（中）",
    feature: "ツーバイ材。小型家具・箱枠・脚材。呼び寸45×45に相当" },

  { w: 89, t: 38,  iname: "SPF 2×4材",     hname: "角材（中）または2×4材",
    feature: "棚板・天板・枠材。日本のDIYで最もポピュラーなツーバイ材。" },

  { w: 140, t: 38, iname: "SPF 2×6材",     hname: "角材（厚）または2×6材",
    feature: "ワイドな棚板・ベンチ天板などに使用。" },

  { w: 89, t: 89,  iname: "SPF 4×4材",     hname: "角材（太）または4×4材",
    feature: "テーブル脚・門柱・大工作業向き。呼び寸90×90に相当" }

]

now = Time.current
payload = rows.each_with_index.map do |r, i|
  w = r[:w]; t = r[:t]
  code = "#{w}x#{t}"
  {
    code:          code,
    width_mm:      w,
    thickness_mm:  t,
    industry_name: r[:iname],
    hc_name:       r[:hname],
    feature:       r[:feature],
    sort_order:    i,
    deleted_flag:  false,
    created_at:    now,
    updated_at:    now
  }
end

MLumberSize.upsert_all(payload, unique_by: :code)
