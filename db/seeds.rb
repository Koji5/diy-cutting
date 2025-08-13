# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 実行コマンド（Docker開発環境）
#   docker compose exec app rails db:seed
# または個別実行：
#   docker compose exec app rails runner db/seeds/local/40_banks.rb

if Rails.env.development?
  Dir[Rails.root.join("db/seeds/local/*.rb")].sort.each { |f| load f }

#----------------------------------------
# --- 部品系マスタ 初期値 ---
#   必要最低限。後続で CSV インポート等で拡張する
#----------------------------------------

# === 1) カテゴリ ========================
MCategory.upsert_all([
  { code: "WOOD",  name_ja: "木材",  name_en: "Wood"  },
  { code: "METAL", name_ja: "金属",  name_en: "Metal" }
])

# === 2) 材質 ============================
# m_materials を「追加だけ」で投入（既存は更新しない）
# 必須: category_code "WOOD" が m_categories に存在すること

MMaterial.upsert_all([
  # 合板・ボード系
  {
    code: "lauan_plywood",
    category_code: "WOOD",
    name_ja: "ラワン合板",
    name_en: "Lauan Plywood",
    description_ja: "ラワン（南洋材）を芯にした汎用合板。内装・造作向け。",
    description_en: "General-purpose plywood (meranti/laun veneers).",
    jis_iso: "JAS Plywood",          # JAS系の合板規格
    density_kg_per_m3: 590.0          # 目安：ラワンの平均比重域から
  },
  {
    code: "shina_plywood",
    category_code: "WOOD",
    name_ja: "シナベニヤ",
    name_en: "Shina (Basswood) Plywood",
    description_ja: "表面にシナ材単板。塗装性・加工性が高い軽量合板。",
    description_en: "Basswood-faced plywood for fine finishing.",
    jis_iso: "JAS Plywood",
    density_kg_per_m3: 450.0          # 目安：バスウッドの中庸域
  },
  {
    code: "mdf",
    category_code: "WOOD",
    name_ja: "MDF",
    name_en: "Medium Density Fiberboard",
    description_ja: "中密度繊維板。フラットで塗装・切削性に優れる。",
    description_en: "Flat, machinable panel for painting and routing.",
    jis_iso: "JIS A5905",             # 繊維板
    density_kg_per_m3: 750.0          # 一般的なMDFの代表値
  },
  {
    code: "osb",
    category_code: "WOOD",
    name_ja: "OSB",
    name_en: "Oriented Strand Board",
    description_ja: "配向ストランドボード。構造用下地などに用いる。",
    description_en: "Engineered structural panel made from oriented strands.",
    jis_iso: "JIS A5908",             # パーティクルボード系（構造用含む）
    density_kg_per_m3: 640.0          # 一般的な代表値
  },

  # 集成材・製材
  {
    code: "pine_glulam",
    category_code: "WOOD",
    name_ja: "パイン集成材",
    name_en: "Pine Glulam",
    description_ja: "パイン小角の集成材。造作用に広く利用。",
    description_en: "Pine glued-laminated timber for interior use.",
    jis_iso: "JAS1152",               # 集成材
    density_kg_per_m3: 450.0
  },
  {
    code: "sugi_glulam",
    category_code: "WOOD",
    name_ja: "杉集成材",
    name_en: "Sugi Glulam (Cedar)",
    description_ja: "国産杉の集成材。軽量で加工性に優れる。",
    description_en: "Japanese cedar glulam; light and easy to machine.",
    jis_iso: "JAS1152",
    density_kg_per_m3: 380.0
  },
  {
    code: "spf",
    category_code: "WOOD",
    name_ja: "SPF材",
    name_en: "SPF Lumber",
    description_ja: "スプルース・パイン・ファーの北米製材の総称。",
    description_en: "Spruce-Pine-Fir softwood lumber group.",
    jis_iso: "JAS1083",               # 製材（構造用を含む）
    density_kg_per_m3: 400.0          # 代表値（Spruce/Pine/Firの中庸）
  },
  {
    code: "sugi",
    category_code: "WOOD",
    name_ja: "杉（国産）",
    name_en: "Japanese Cedar (Sugi)",
    description_ja: "軽量で加工しやすい国産針葉樹。内装・造作向け。",
    description_en: "Lightweight Japanese cedar for interior/joinery.",
    jis_iso: "JAS1083",
    density_kg_per_m3: 380.0          # 乾燥密度の代表域から
  },
  {
    code: "hinoki",
    category_code: "WOOD",
    name_ja: "ヒノキ",
    name_en: "Hinoki Cypress",
    description_ja: "高耐久・芳香が特長の国産材。造作・建具材に。",
    description_en: "Durable, aromatic Japanese cypress.",
    jis_iso: "JAS1083",
    density_kg_per_m3: 380.0          # 比重0.38相当
  },
  {
    code: "douglas_fir",
    category_code: "WOOD",
    name_ja: "米松",
    name_en: "Douglas Fir (Oregon)",
    description_ja: "強度に優れた外来針葉樹。構造・枠材に好適。",
    description_en: "Strong softwood for structural and framing.",
    jis_iso: "JAS1083",
    density_kg_per_m3: 530.0
  },
  {
    code: "whitewood",
    category_code: "WOOD",
    name_ja: "ホワイトウッド",
    name_en: "Whitewood (Spruce)",
    description_ja: "欧州トウヒ系の総称。内装・造作や枠材向け。",
    description_en: "European spruce group for interior/framing.",
    jis_iso: "JAS1083",
    density_kg_per_m3: 470.0
  }
])

# === 3) 形状マスタ（最新版） =========================
MShape.upsert_all([
  {
    code: "RECT",
    name_ja: "四角形",
    name_en: "Rectangle",
    description_ja: "加工のない板の状態。平面加工と断面加工でお好みの形状にできます",
    description_en: "Plain rectangular board. Combine with edge/shape processes as needed.",
    allow_shape_json: [],
    allow_corner_json: %w[tl tr bl br],
    allow_edge_json:   %w[t l r b]
  },
  {
    code: "CORNER_R1",
    name_ja: "片角アール加工",
    name_en: "Single-Corner Rounded",
    description_ja: "1つの角にアール加工をつける形状",
    description_en: "Rounded on one corner.",
    allow_shape_json:  %w[bl],
    allow_corner_json: %w[tl tr br],
    allow_edge_json:   %w[t l r b bl]
  },
  {
    code: "SIDE_ARC1",
    name_ja: "片側アール加工",
    name_en: "Single-Side Arc",
    description_ja: "片側にアール加工をつける形状",
    description_en: "Arc on one long side.",
    allow_shape_json:  %w[tl bl],
    allow_corner_json: %w[tr br],
    allow_edge_json:   %w[tl t l r b bl]
  },
  {
    code: "SIDE_UARC1",
    name_ja: "片側U型アール加工",
    name_en: "Single-Side U-Shaped Cut",
    description_ja: "片側に半円のアール加工をつける形状",
    description_en: "U-shaped cut on one side.",
    allow_shape_json: [],
    allow_corner_json: %w[tr br],
    allow_edge_json:   %w[tl t r b bl l]
  },
  {
    code: "TRI_EQ",
    name_ja: "正三角形",
    name_en: "Equilateral Triangle",
    description_ja: "板からくり抜いた正三角形の形状",
    description_en: "Equilateral triangular plate.",
    allow_shape_json: [],
    allow_corner_json: [],
    allow_edge_json:   %w[tl tr b]
  },
  {
    code: "CORNER_R2",
    name_ja: "両角アール加工",
    name_en: "Opposite-Corner Rounded",
    description_ja: "両角にアール加工をつける形状",
    description_en: "Rounded on two opposite corners.",
    allow_shape_json:  %w[bl br],
    allow_corner_json: %w[tl tr],
    allow_edge_json:   %w[t l r bl b br]
  },
  {
    code: "CORNER_R4",
    name_ja: "全角アール加工",
    name_en: "All-Corner Rounded",
    description_ja: "全ての角にアール加工をつける形状",
    description_en: "Rounded on all four corners.",
    allow_shape_json:  %w[tl tr bl br],
    allow_corner_json: [],
    allow_edge_json:   %w[tl t tr l r bl b br]
  },
  {
    code: "SIDE_UARC2",
    name_ja: "両側U型アール加工",
    name_en: "Both-Side U-Shaped Cut",
    description_ja: "両側に半円のアール加工をつける形状",
    description_en: "U-shaped cuts on both sides.",
    allow_shape_json: [],
    allow_corner_json: [],
    allow_edge_json:   %w[tl t tr bl b br]
  },
  {
    code: "CIRC",
    name_ja: "円型",
    name_en: "Circle",
    description_ja: "板からくり抜いた円の形状",
    description_en: "Circular plate.",
    allow_shape_json: [],
    allow_corner_json: [],
    allow_edge_json:   %w[tl tr br bl]
  },
  {
    code: "SEMI",
    name_ja: "半円型",
    name_en: "Semicircle",
    description_ja: "板からくり抜いた半円の形状",
    description_en: "Semicircular plate.",
    allow_shape_json: [],
    allow_corner_json: [],
    allow_edge_json:   %w[bl br t]
  },
  {
    code: "NICHE",
    name_ja: "ニッチ型加工",
    name_en: "Niche",
    description_ja: "飾り棚に最適です",
    description_en: "Niche-shaped cut-out.",
    allow_shape_json: [],
    allow_corner_json: %w[bl br],
    allow_edge_json:   %w[t l r b]
  },
  {
    code: "CORNER_TRI",
    name_ja: "コーナーA型",
    name_en: "Corner Triangle",
    description_ja: "扇型の形状 コーナーに最適です",
    description_en: "Fan-shaped corner piece.",
    allow_shape_json: [],
    allow_corner_json: %w[tr],
    allow_edge_json:   %w[t r bl]
  }
])


# === コーナー加工マスタ ============================
MCornerProcess.upsert_all([
  {
    code:  "NONE",
    name_ja: "加工しない",
    name_en: "None",
    description_ja: nil,
    description_en: nil,
    allow_corner_proc_json: []
  },
  {
    code:  "ROUND_R",
    name_ja: "角丸め",
    name_en: "Round (R)",
    description_ja: nil,
    description_en: nil,
    allow_corner_proc_json: %w[r]          # r 指定
  },
  {
    code:  "CHAMFER",
    name_ja: "角落とし",
    name_en: "Chamfer",
    description_ja: nil,
    description_en: nil,
    allow_corner_proc_json: %w[dx dy]      # 面取り dx・dy
  },
  {
    code:  "BEVEL",
    name_ja: "斜めカット",
    name_en: "Bevel Cut",
    description_ja: nil,
    description_en: nil,
    allow_corner_proc_json: %w[dx dy]      # 斜めカット長
  },
  {
    code:  "INROUND",
    name_ja: "内丸め",
    name_en: "Inner Round",
    description_ja: nil,
    description_en: nil,
    allow_corner_proc_json: %w[r]          # 内側 R
  }
])

# === 丸穴径マスタ ==============================================
MHoleDiameter.upsert_all([
  { code: "D03", hole_mm: 3.0,  name_ja: "3mm",  name_en: "Ø3"  },
  { code: "D06", hole_mm: 6.0,  name_ja: "6mm",  name_en: "Ø6"  },
  { code: "D09", hole_mm: 9.0,  name_ja: "9mm",  name_en: "Ø9"  },
  { code: "D12", hole_mm: 12.0, name_ja: "12mm", name_en: "Ø12" },
  { code: "D16P", hole_mm: 16.0, name_ja: "16mm以上", name_en: "Ø16+" }
])

# === 断面加工マスタ ==================================================
MEdgeProcess.upsert_all([
  {
    code:  "NONE",
    name_ja: "断面加工なし",
    name_en: "None",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "CHAMF_BTH",
    name_ja: "上下糸面",
    name_en: "Chamfer",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "BULLNOSE",
    name_ja: "ボーズ面",
    name_en: "Bullnose",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "CHM5MM",
    name_ja: "上下5mm面",
    name_en: "Chamf 5mm",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "CHM10MM",
    name_ja: "上下10mm面",
    name_en: "Chamf10mm",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "R5ROUND",
    name_ja: "上下5R面",
    name_en: "R5Round",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "R10ROUND",
    name_ja: "上下10R面",
    name_en: "R10Round",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "COVE",
    name_ja: "ギンナン面",
    name_en: "Cove",
    description_ja: nil,
    description_en: nil
  },
  {
    code:  "OGEE",
    name_ja: "船底面",
    name_en: "Ogee",
    description_ja: nil,
    description_en: nil
  }
])

end
