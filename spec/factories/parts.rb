# frozen_string_literal: true
#
# spec/factories/parts.rb
#
FactoryBot.define do
  factory :part do
    # ─────────────────────────────────────────────
    # 必須関連（belongs_to）
    # ─────────────────────────────────────────────
    association :user

    # ─────────────────────────────────────────────
    # JSON フィールド – デフォルトは空
    # ─────────────────────────────────────────────
    shape_json        { {} }
    corner_proc_json  { {} }
    hole_json         { {} }
    sqhole_json       { {} }
    edge_json         { {} }
    paint_json        { {} }

    material_category_code { "WOOD" }
    name { "test" }
    material_code { "PLY_BIRCH" }
    shape_code { "RECT" }
    thickness_mm { "20" }
    width1_mm { "300" }
    length_mm { "1000" }
    corner_tl_r { "50" }
    hole_tl_flag { "1" }
    hole_tl_dy { "50" }
    hole_tl_dx { "68" }
    hole_tl_dia_code { "D12" }
    hole_tr_flag { "0" }
    hole_bl_flag { "0" }
    hole_br_flag { "0" }
    sqhole_tl_flag { "0" }
    sqhole_tr_flag { "0" }
    sqhole_bl_flag { "0" }
    sqhole_br_flag { "0" }
    edge_t_code { "NONE" }
    edge_l_code { "NONE" }
    edge_r_code { "NONE" }
    edge_b_code { "NONE" }
    paint_type_code { "NONE" }
    corner_bl_code { "NONE" }
    corner_br_code { "NONE" }
    corner_tl_code { "INROUND" }
    corner_tr_code { "NONE" }
    # ─────────────────────────────────────────────
    # トレイト：よく使う形状
    # ─────────────────────────────────────────────
    trait :triangle do
      shape_code  { "TRI_EQ" }
      width1_mm   { 150.0 }
      length_mm   { 150.0 }
    end

    trait :niche do
      shape_code { "NICHE" }
      width1_mm  { 100.0 }
      width2_mm  { 180.0 }   # 張り出し
    end

    trait :rounded_corners do
      corner_proc_json do
        {
          corner_tl_code: "ROUND_R", corner_tl_r: 5,
          corner_tr_code: "ROUND_R", corner_tr_r: 5,
          corner_bl_code: "ROUND_R", corner_bl_r: 5,
          corner_br_code: "ROUND_R", corner_br_r: 5
        }
      end
    end

    # ─────────────────────────────────────────────
    # after(:build) などで JSON をまとめてセットする例
    # ─────────────────────────────────────────────
    trait :with_holes do
      transient do
        hole_diameter { 10.0 }
        hole_offset   { 15.0 }
      end

      after(:build) do |part, evaluator|
        part.hole_json = {
          hole_tl_flag: true, hole_tl_dia_mm: evaluator.hole_diameter,
          hole_tl_dx:   evaluator.hole_offset, hole_tl_dy: evaluator.hole_offset
        }
      end
    end
  end
end
