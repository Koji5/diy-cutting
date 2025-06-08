# frozen_string_literal: true

module MasterLoader
  def self.load!

    MCategory.find_or_create_by!(code: "METAL") { |m| m.assign_attributes(name_ja: "金属", name_en: "Metal") }
    MCategory.find_or_create_by!(code: "WOOD") { |m| m.assign_attributes(name_ja: "木材", name_en: "Wood") }

    MMaterial.find_or_create_by!(code: "PLY_BIRCH") { |m| m.assign_attributes(category_code: "WOOD", name_ja: "シナ合板", name_en: "Birch Plywood", density_kg_per_m3: 0.68e3) }
    MMaterial.find_or_create_by!(code: "SOLID_OAK") { |m| m.assign_attributes(category_code: "WOOD", name_ja: "ナラ無垢", name_en: "Solid Oak", density_kg_per_m3: 0.72e3) }
    MMaterial.find_or_create_by!(code: "SS400") { |m| m.assign_attributes(category_code: "METAL", name_ja: "一般構造用圧延鋼材", name_en: "Steel SS400", density_kg_per_m3: 0.785e4) }

    MShape.find_or_create_by!(code: "CIRC") { |m| m.assign_attributes(name_ja: "円型", name_en: "Circle") }
    MShape.find_or_create_by!(code: "CORNER_R1") { |m| m.assign_attributes(name_ja: "片角アール加工", name_en: "Single-Corner Rounded") }
    MShape.find_or_create_by!(code: "CORNER_R2") { |m| m.assign_attributes(name_ja: "両角アール加工", name_en: "Opposite-Corner Rounded") }
    MShape.find_or_create_by!(code: "CORNER_R4") { |m| m.assign_attributes(name_ja: "全角アール加工", name_en: "All-Corner Rounded") }
    MShape.find_or_create_by!(code: "CORNER_TRI") { |m| m.assign_attributes(name_ja: "コーナーA型", name_en: "Corner Triangle") }
    MShape.find_or_create_by!(code: "NICHE") { |m| m.assign_attributes(name_ja: "ニッチ型加工", name_en: "Niche") }
    MShape.find_or_create_by!(code: "RECT") { |m| m.assign_attributes(name_ja: "四角形", name_en: "Rectangle") }
    MShape.find_or_create_by!(code: "SEMI") { |m| m.assign_attributes(name_ja: "半円型", name_en: "Semicircle") }
    MShape.find_or_create_by!(code: "SIDE_ARC1") { |m| m.assign_attributes(name_ja: "片側アール加工", name_en: "Single-Side Arc") }
    MShape.find_or_create_by!(code: "SIDE_UARC1") { |m| m.assign_attributes(name_ja: "片側U型アール加工", name_en: "Single-Side U-Shaped Cut") }
    MShape.find_or_create_by!(code: "SIDE_UARC2") { |m| m.assign_attributes(name_ja: "両側U型アール加工", name_en: "Both-Side U-Shaped Cut") }
    MShape.find_or_create_by!(code: "TRI_EQ") { |m| m.assign_attributes(name_ja: "正三角形", name_en: "Equilateral Triangle") }

    MCornerProcess.find_or_create_by!(code: "BEVEL") { |m| m.assign_attributes(name_ja: "斜めカット", name_en: "Bevel Cut") }
    MCornerProcess.find_or_create_by!(code: "CHAMFER") { |m| m.assign_attributes(name_ja: "角落とし", name_en: "Chamfer") }
    MCornerProcess.find_or_create_by!(code: "INROUND") { |m| m.assign_attributes(name_ja: "内丸め", name_en: "Inner Round") }
    MCornerProcess.find_or_create_by!(code: "NONE") { |m| m.assign_attributes(name_ja: "加工しない", name_en: "None") }
    MCornerProcess.find_or_create_by!(code: "ROUND_R") { |m| m.assign_attributes(name_ja: "角丸め", name_en: "Round (R)") }

    MEdgeProcess.find_or_create_by!(code: "BULLNOSE") { |m| m.assign_attributes(name_ja: "ボーズ面", name_en: "Bullnose") }
    MEdgeProcess.find_or_create_by!(code: "CHAMF_BTH") { |m| m.assign_attributes(name_ja: "上下糸面", name_en: "Chamfer") }
    MEdgeProcess.find_or_create_by!(code: "CHM10MM") { |m| m.assign_attributes(name_ja: "上下10mm面", name_en: "Chamf10mm") }
    MEdgeProcess.find_or_create_by!(code: "CHM5MM") { |m| m.assign_attributes(name_ja: "上下5mm面", name_en: "Chamf 5mm") }
    MEdgeProcess.find_or_create_by!(code: "COVE") { |m| m.assign_attributes(name_ja: "ギンナン面", name_en: "Cove") }
    MEdgeProcess.find_or_create_by!(code: "NONE") { |m| m.assign_attributes(name_ja: "断面加工なし", name_en: "None") }
    MEdgeProcess.find_or_create_by!(code: "OGEE") { |m| m.assign_attributes(name_ja: "船底面", name_en: "Ogee") }
    MEdgeProcess.find_or_create_by!(code: "R10ROUND") { |m| m.assign_attributes(name_ja: "上下10R面", name_en: "R10Round") }
    MEdgeProcess.find_or_create_by!(code: "R5ROUND") { |m| m.assign_attributes(name_ja: "上下5R面", name_en: "R5Round") }

    MHoleDiameter.find_or_create_by!(code: "D03") { |m| m.assign_attributes(hole_mm: 0.3e1, name_ja: "3mm", name_en: "Ø3") }
    MHoleDiameter.find_or_create_by!(code: "D06") { |m| m.assign_attributes(hole_mm: 0.6e1, name_ja: "6mm", name_en: "Ø6") }
    MHoleDiameter.find_or_create_by!(code: "D08") { |m| m.assign_attributes(hole_mm: 0.8e1, name_ja: "8mm", name_en: "Ø8") }
    MHoleDiameter.find_or_create_by!(code: "D09") { |m| m.assign_attributes(hole_mm: 0.9e1, name_ja: "9mm", name_en: "Ø9") }
    MHoleDiameter.find_or_create_by!(code: "D12") { |m| m.assign_attributes(hole_mm: 0.12e2, name_ja: "12mm", name_en: "Ø12") }
    MHoleDiameter.find_or_create_by!(code: "D16P") { |m| m.assign_attributes(hole_mm: 0.16e2, name_ja: "16mm以上", name_en: "Ø16+") }

    MPaintSurface.find_or_create_by!(code: "ALL") { |m| m.assign_attributes(name_ja: "全面塗装", name_en: "All-Over") }
    MPaintSurface.find_or_create_by!(code: "STD") { |m| m.assign_attributes(name_ja: "標準塗装", name_en: "Standard") }

    MPaintColor.find_or_create_by!(code: "CL") { |m| m.assign_attributes(name_ja: "クリアー（透明）", name_en: "Clear") }
    MPaintColor.find_or_create_by!(code: "DK") { |m| m.assign_attributes(name_ja: "ダーク", name_en: "Dark") }
    MPaintColor.find_or_create_by!(code: "LT") { |m| m.assign_attributes(name_ja: "ライト", name_en: "Light") }
    MPaintColor.find_or_create_by!(code: "MD") { |m| m.assign_attributes(name_ja: "ミディアム", name_en: "Medium") }
    MPaintColor.find_or_create_by!(code: "MT") { |m| m.assign_attributes(name_ja: "色合わせ", name_en: "Match") }
    MPaintColor.find_or_create_by!(code: "WH") { |m| m.assign_attributes(name_ja: "ホワイト", name_en: "White") }

    MGrainFinish.find_or_create_by!(code: "CL") { |m| m.assign_attributes(name_ja: "クローズ塗装", name_en: "Closed") }
    MGrainFinish.find_or_create_by!(code: "OP") { |m| m.assign_attributes(name_ja: "セミオープン塗装(標準)", name_en: "Semi-Open") }
    MGrainFinish.find_or_create_by!(code: "SOL") { |m| m.assign_attributes(name_ja: "塗りつぶし", name_en: "Solid") }

    MGloss.find_or_create_by!(code: "G00") { |m| m.assign_attributes(name_ja: "全消し", name_en: "Flat", gloss_pct: 0) }
    MGloss.find_or_create_by!(code: "G100") { |m| m.assign_attributes(name_ja: "全ツヤ", name_en: "Full Gloss", gloss_pct: 100) }
    MGloss.find_or_create_by!(code: "G30") { |m| m.assign_attributes(name_ja: "3分ツヤ(標準)", name_en: "30% Gloss", gloss_pct: 30) }
    MGloss.find_or_create_by!(code: "G50") { |m| m.assign_attributes(name_ja: "5分ツヤ", name_en: "50% Gloss", gloss_pct: 50) }

    MPaintType.find_or_create_by!(code: "NONE") { |m| m.assign_attributes(name_ja: "選択なし", name_en: "None") }
    MPaintType.find_or_create_by!(code: "NTRL") { |m| m.assign_attributes(name_ja: "自然塗装", name_en: "Natural Oil") }
    MPaintType.find_or_create_by!(code: "URTH") { |m| m.assign_attributes(name_ja: "ウレタン塗装", name_en: "Polyurethane") }

    cache = MHoleDiameter.pluck(:code, :hole_mm).to_h.freeze
    Object.send(:remove_const, :HOLE_DIAMETERS) if Object.const_defined?(:HOLE_DIAMETERS)
    Object.const_set(:HOLE_DIAMETERS, cache)
  end
end
