# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if Rails.env.development?
  Dir[Rails.root.join("db/seeds/local/*.rb")].sort.each { |f| load f }

  # ───────────────────────────────
  # 開発環境専用：管理者ユーザーを 1 件だけ用意
  # ───────────────────────────────
  admin_email    = "admin@example.dev"
  admin_password = "123456"

  admin = User.find_or_create_by!(email: admin_email) do |u|
    u.password              = admin_password
    u.password_confirmation = admin_password
    u.role                  = :admin                 # enum { member:0, vendor:1, admin:2, affiliate:3 }
    u.public_uid            ||= SecureRandom.urlsafe_base64(24)
  end

  # AdminDetail がまだ無ければ作成
  if admin.admin_detail.nil?
    admin.build_admin_detail(
      nickname:   "DevMaster",
      icon_url:   nil,
      department: "Development"
    )
    admin.save!
    puts <<~MSG
      [seed] 開発用管理者ユーザーを作成／更新しました
            email:    #{admin_email}
            password: #{admin_password}
    MSG
  end

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
MMaterial.upsert_all([
  {
    code:              "PLY_BIRCH",
    category_code:     "WOOD",
    name_ja:           "シナ合板",
    name_en:           "Birch Plywood",
    jis_iso:           nil,            # ← 全行に同じキー
    density_kg_per_m3: 680
  },
  {
    code:              "SOLID_OAK",
    category_code:     "WOOD",
    name_ja:           "ナラ無垢",
    name_en:           "Solid Oak",
    jis_iso:           nil,
    density_kg_per_m3: 720
  },
  {
    code:              "SS400",
    category_code:     "METAL",
    name_ja:           "一般構造用圧延鋼材",
    name_en:           "Steel SS400",
    jis_iso:           "JIS G3101",
    density_kg_per_m3: 7850
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

# === 塗装種別マスタ ================================================
MPaintType.upsert_all([
  {
    code: "NONE",
    name_ja: "選択なし",
    name_en: "None",
    allow_paint_json: {
      surfaces: [],
      colors:   [],
      grains:   [],
      glosses:  []
    }
  },
  {
    code: "URTH",
    name_ja: "ウレタン塗装",
    name_en: "Polyurethane",
    allow_paint_json: {
      surfaces: %w[STD ALL],
      colors:   %w[CL LT MD DK WH MT],
      grains:   %w[OP CL SOL],
      glosses:  %w[G00 G30 G50 G100]
    }
  },
  {
    code: "NTRL",
    name_ja: "自然塗装",
    name_en: "Natural Oil",
    allow_paint_json: {
      surfaces: %w[STD ALL],
      colors:   %w[CL],
      grains:   [],
      glosses:  []
    }
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

# === 8) 塗装面 ==========================
MPaintSurface.upsert_all([
  { code: "STD", name_ja: "標準塗装", name_en: "Standard" },
  { code: "ALL", name_ja: "全面塗装", name_en: "All-Over" }
])

# === 9) 塗装色 ==========================
MPaintColor.upsert_all([
  { code: "CL", name_ja: "クリアー（透明）", name_en: "Clear"  },
  { code: "LT", name_ja: "ライト",           name_en: "Light"  },
  { code: "MD", name_ja: "ミディアム",       name_en: "Medium" },
  { code: "DK", name_ja: "ダーク",           name_en: "Dark"   },
  { code: "WH", name_ja: "ホワイト",         name_en: "White"  },
  { code: "MT", name_ja: "色合わせ",         name_en: "Match"  }
])

# === 10) 導管・木目仕上げ ===============
MGrainFinish.upsert_all([
  { code: "OP",  name_ja: "セミオープン塗装(標準)", name_en: "Semi-Open" },
  { code: "CL",  name_ja: "クローズ塗装",           name_en: "Closed"    },
  { code: "SOL", name_ja: "塗りつぶし",             name_en: "Solid"     }
])

# === 11) ツヤ ===========================
MGloss.upsert_all([
  { code: "G00",  gloss_pct: 0,   name_ja: "全消し",          name_en: "Flat"       },
  { code: "G30",  gloss_pct: 30,  name_ja: "3分ツヤ(標準)",    name_en: "30% Gloss" },
  { code: "G50",  gloss_pct: 50,  name_ja: "5分ツヤ",         name_en: "50% Gloss" },
  { code: "G100", gloss_pct: 100, name_ja: "全ツヤ",          name_en: "Full Gloss"}
])

end
