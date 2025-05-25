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

# === 3) 形状 ============================
MShape.upsert_all([
  { code: "RECT",     name_ja: "矩形",   name_en: "Rectangle",
    allow_shape_json:  "{}", allow_corner_json: "{}", allow_edge_json: "{}" },
  { code: "TRIANGLE", name_ja: "三角形", name_en: "Triangle",
    allow_shape_json:  "{}", allow_corner_json: "{}", allow_edge_json: "{}" }
])

# === 4) 塗装種別 ========================
MPaintType.upsert_all([
  { code: "URTH", name_ja: "ウレタン塗装", name_en: "Polyurethane",
    allow_paint_json: "{}" },
  { code: "NTRL", name_ja: "自然塗装",   name_en: "Natural Oil",
    allow_paint_json: "{}" }
])

# === 5) コーナー加工 ====================
MCornerProcess.upsert_all([
  { code: "NONE",   name_ja: "なし",   name_en: "None" },
  { code: "ROUND",  name_ja: "丸め",   name_en: "Round" },
  { code: "CHAMFER",name_ja: "面取り", name_en: "Chamfer" }
])

# === 6) 丸穴径 ==========================
MHoleDiameter.upsert_all([
  { code: "D06", hole_mm: 6.0, name_ja: "6mm", name_en: "Ø6" },
  { code: "D08", hole_mm: 8.0, name_ja: "8mm", name_en: "Ø8" }
])

# === 7) 断面加工 ========================
MEdgeProcess.upsert_all([
  { code: "NONE",  name_ja: "なし",   name_en: "None" },
  { code: "BEVEL", name_ja: "45°面", name_en: "Bevel" },
  { code: "ROUND", name_ja: "R面",   name_en: "Round" }
])

# === 8) 塗装面 ==========================
MPaintSurface.upsert_all([
  { code: "STD", name_ja: "標準面", name_en: "Standard" },
  { code: "ALL", name_ja: "全面",   name_en: "All" }
])

# === 9) 塗装色 ==========================
MPaintColor.upsert_all([
  { code: "CL", name_ja: "クリア",  name_en: "Clear" },
  { code: "LT", name_ja: "ライト",  name_en: "Light" }
])

# === 10) 導管・木目仕上げ ===============
MGrainFinish.upsert_all([
  { code: "OP", name_ja: "セミ OP", name_en: "Semi-Open" },
  { code: "CL", name_ja: "全 CL",  name_en: "Closed" }
])

# === 11) ツヤ ===========================
MGloss.upsert_all([
  { code: "G03", gloss_pct: 30,  name_ja: "3分艶", name_en: "30% Gloss" },
  { code: "G05", gloss_pct: 50,  name_ja: "5分艶", name_en: "50% Gloss" },
  { code: "G100", gloss_pct: 100, name_ja: "全艶",  name_en: "Full Gloss" }
])

end
