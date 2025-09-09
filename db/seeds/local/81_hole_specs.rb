items = [
  # ねじ（メートル）
  { code: "M3",  name_ja: "M3",  name_en: "M3",  category_code: "BOLT_METRIC",
    nominal_mm: 3.0,  pilot_mm: 2.5, countersink_mm: 6.0,
    min_center_center_mm: 10.0, min_edge_distance_mm: 5.0,  sort_order: 10 },

  { code: "M4",  name_ja: "M4",  name_en: "M4",  category_code: "BOLT_METRIC",
    nominal_mm: 4.0,  pilot_mm: 3.2, countersink_mm: 8.0,
    min_center_center_mm: 12.0, min_edge_distance_mm: 6.0,  sort_order: 20 },

  { code: "M5",  name_ja: "M5",  name_en: "M5",  category_code: "BOLT_METRIC",
    nominal_mm: 5.0,  pilot_mm: 4.2, countersink_mm: 10.0,
    min_center_center_mm: 14.0, min_edge_distance_mm: 7.0,  sort_order: 30 },

  { code: "M6",  name_ja: "M6",  name_en: "M6",  category_code: "BOLT_METRIC",
    nominal_mm: 6.0,  pilot_mm: 5.0, countersink_mm: 12.0,
    min_center_center_mm: 16.0, min_edge_distance_mm: 8.0,  sort_order: 40 },

  { code: "M8",  name_ja: "M8",  name_en: "M8",  category_code: "BOLT_METRIC",
    nominal_mm: 8.0,  pilot_mm: 6.5, countersink_mm: 16.0,
    min_center_center_mm: 20.0, min_edge_distance_mm: 10.0, sort_order: 50 },

  { code: "M10", name_ja: "M10", name_en: "M10", category_code: "BOLT_METRIC",
    nominal_mm: 10.0, pilot_mm: 8.5, countersink_mm: 20.0,
    min_center_center_mm: 24.0, min_edge_distance_mm: 12.0, sort_order: 60 },

  # ダボ
  { code: "DOWEL6",  name_ja: "ダボ6mm",  name_en: "Dowel 6mm",  category_code: "DOWEL",
    nominal_mm: 6.0, pilot_mm: 6.0, countersink_mm: nil,
    min_center_center_mm: 10.0, min_edge_distance_mm: 5.0,  sort_order: 110 },

  { code: "DOWEL8",  name_ja: "ダボ8mm",  name_en: "Dowel 8mm",  category_code: "DOWEL",
    nominal_mm: 8.0, pilot_mm: 8.0, countersink_mm: nil,
    min_center_center_mm: 12.0, min_edge_distance_mm: 6.0,  sort_order: 120 },

  { code: "DOWEL10", name_ja: "ダボ10mm", name_en: "Dowel 10mm", category_code: "DOWEL",
    nominal_mm: 10.0, pilot_mm: 10.0, countersink_mm: nil,
    min_center_center_mm: 14.0, min_edge_distance_mm: 7.0,  sort_order: 130 },
]

items.each { |h| MHoleSpec.upsert(h, unique_by: :code) }
