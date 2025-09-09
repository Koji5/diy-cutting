items = [
  { code: "LEFT",   name_ja: "左側面",   name_en: "Left",   sort_order: 10 },
  { code: "TOP",    name_ja: "上側面",   name_en: "Top",    sort_order: 20 },
  { code: "RIGHT",  name_ja: "右側面",   name_en: "Right",  sort_order: 30 },
  { code: "BOTTOM", name_ja: "下側面",   name_en: "Bottom", sort_order: 40 },
  { code: "FRONT",  name_ja: "表面", name_en: "Front",  sort_order: 50 },
  { code: "BACK",   name_ja: "背面", name_en: "Back",   sort_order: 60 },
]
items.each { |h| MHoleSurface.upsert(h, unique_by: :code) }
