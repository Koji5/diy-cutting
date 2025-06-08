# frozen_string_literal: true

# app/lib/ctx_normalizer.rb
# --------------------------------------------------------------
# フォーム or ActiveRecord attributes などの "raw ctx" を
# 外形・穴抽出ロジックで扱いやすい "outer_ctx" へ正規化するユーティリティ。
# 単純な型変換・初期値補完までを担当し、Rails 依存は最小限に保つ。
# --------------------------------------------------------------
module CtxNormalizer
  module_function

  SHAPES_R_TL = %w[CORNER_R1 CORNER_R4 SIDE_UARC1 SIDE_UARC2 CIRC SEMI].freeze
  SHAPES_R_TR = %w[CORNER_R4 SIDE_UARC2 CIRC SEMI].freeze
  SHAPES_R_BL = %w[CORNER_R1 SIDE_ARC1 SIDE_UARC1 CORNER_R2 CORNER_R4 SIDE_UARC2 CIRC CORNER_TRI].freeze
  SHAPES_R_BR = %w[CORNER_R1 CORNER_R2 SIDE_UARC2 CIRC].freeze

  SHAPES_NONE_TL = %w[TRI_EQ NICHE CORNER_TRI].freeze
  SHAPES_NONE_TR = %w[TRI_EQ NICHE].freeze
  SHAPES_NONE_BL = %w[TRI_EQ SEMI].freeze
  SHAPES_NONE_BR = %w[TRI_EQ SEMI CORNER_TRI].freeze

  # --------------------------------------------------------------
  # Public: 生 ctx を受け取り、正規化済みハッシュを返す
  #
  # @param raw [Hash, ActiveSupport::HashWithIndifferentAccess]
  # @return [Hash] 深くシンボル化され、数値は Float へ統一
  #
  # 使用側 (GeometryChecks / OuterShapeBuilder など) では
  #   ctx = CtxNormalizer.call(raw_ctx)
  # として利用する想定。
  # ------------------------------------------------------------
  def call(raw)
    shp   = raw[:shape_code]
    sjson = (raw[:shape_json] || {}).symbolize_keys       # ActiveSupport 依存
    cjson = (raw[:corner_proc_json] || {}).symbolize_keys # ActiveSupport 依存

    {
      shape_code:  shp,
      width1_mm:   raw[:width1_mm].to_f,
      width2_mm:   raw[:width2_mm].to_f,
      length_mm:   raw[:length_mm].to_f,

      # --- corner codes ---
      corner_tl_code: calc_code(shp, SHAPES_R_TL, SHAPES_NONE_TL, cjson[:corner_tl_code]),
      corner_tr_code: calc_code(shp, SHAPES_R_TR, SHAPES_NONE_TR, cjson[:corner_tr_code]),
      corner_bl_code: calc_code(shp, SHAPES_R_BL, SHAPES_NONE_BL, cjson[:corner_bl_code]),
      corner_br_code: calc_code(shp, SHAPES_R_BR, SHAPES_NONE_BR, cjson[:corner_br_code]),

      # --- corner radii ---
      corner_tl_r:   SHAPES_R_TL.include?(shp) ? sjson[:shape_tl_r].to_f : cjson[:corner_tl_r].to_f,
      corner_tr_r:   SHAPES_R_TR.include?(shp) ? sjson[:shape_tr_r].to_f : cjson[:corner_tr_r].to_f,
      corner_bl_r:   SHAPES_R_BL.include?(shp) ? sjson[:shape_bl_r].to_f : cjson[:corner_bl_r].to_f,
      corner_br_r:   SHAPES_R_BR.include?(shp) ? sjson[:shape_br_r].to_f : cjson[:corner_br_r].to_f,

      # --- offset params ---
      corner_tl_dx:  cjson[:corner_tl_dx].to_f,
      corner_tr_dx:  cjson[:corner_tr_dx].to_f,
      corner_bl_dx:  cjson[:corner_bl_dx].to_f,
      corner_br_dx:  cjson[:corner_br_dx].to_f,
      corner_tl_dy:  cjson[:corner_tl_dy].to_f,
      corner_tr_dy:  cjson[:corner_tr_dy].to_f,
      corner_bl_dy:  cjson[:corner_bl_dy].to_f,
      corner_br_dy:  cjson[:corner_br_dy].to_f
    }
  end

  # ============================================================
  # private helpers
  # ============================================================

  # 共通ヘルパー : shape_code と定数テーブルから最終コードを返す
  def calc_code(shape, round_list, none_list, fallback)
    return "ROUND_R" if round_list.include?(shape)
    return "NONE"    if none_list.include?(shape)
    fallback
  end
end
