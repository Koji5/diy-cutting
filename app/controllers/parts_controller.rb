class PartsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_member_or_affiliate

  # ───────────────────────
  # 一覧 (SID-PR-100)
  # ───────────────────────
  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @parts = current_user.parts.alive.includes(:origin_owner).order(updated_at: :desc)
    # affiliate の場合のみ “オリジナル作成者” を表示するため
    @show_owner = current_user.affiliate?
  end

  def new
    @part = Part.new
    load_masters
  end

  def create
    @part = current_user.parts.build(basic_part_params)   # 基本カラム
    @part.material_category_code ||= "WOOD"
    #   ↑ フォームで送られていなければ強制的に WOOD をセット
    #   （将来カテゴリ選択式にしたときはこの行を削除 or 条件分岐）

    if @part.save
      redirect_to parts_path, notice: "部品を登録しました"
    else
      load_masters
      render :new, status: :unprocessable_entity
    end
  end

  private

  # ロールチェック（member or affiliate）
  def require_member_or_affiliate
    return if current_user.member? || current_user.affiliate?

    render file: Rails.root.join("public/403.html"),
           status: :forbidden, layout: false
  end

  # ───────────────────────
  # 各種マスタ一括ロード
  # ───────────────────────
  def load_masters
    # --- 基本マスタ -------------------------------------------------
    @material_categories = MCategory.order(:code)
    @materials           = MMaterial.order(:code)
    @shapes              = MShape.order(:code)

    # --- 加工マスタ -------------------------------------------------
    @edge_processes      = MEdgeProcess.order(:code)
    @corner_processes    = MCornerProcess.order(:code)
    @hole_diameters      = MHoleDiameter.order(:hole_mm)

    # --- 塗装マスタ -------------------------------------------------
    @paint_types     = MPaintType.order(:code)
    @paint_surfaces  = MPaintSurface.order(:code)
    @paint_colors    = MPaintColor.order(:code)
    @grain_finishes  = MGrainFinish.order(:code)
    @glosses         = MGloss.order(:code)

    # --- グローバルルール -----------------------------------------
    @global_dim_rule = GLOBAL_DIM_RULE

    # ---------- Stimulus へ渡す JSON まとめ ---------- #
    @shape_rules = {
      shape:  @shapes.index_by(&:code).transform_values(&:allow_shape_json),
      corner: @shapes.index_by(&:code).transform_values(&:allow_corner_json),
      edge:   @shapes.index_by(&:code).transform_values(&:allow_edge_json)
    }.to_json

    @corner_proc_rules = @corner_processes
                           .index_by(&:code)
                           .transform_values(&:allow_corner_proc_json)
                           .to_json

    @paint_type_rules  = @paint_types
                           .index_by(&:code)
                           .transform_values(&:allow_paint_json)
                           .to_json
  end


    # ───────── 基本項目 (テーブルの直接カラム) ─────────
  def basic_part_params
    params.require(:part).permit(
      :name, :material_category_code, :material_code, :shape_code, :paint_type_code, 
      :thickness_mm, :width1_mm, :width2_mm, :length_mm, :note,
      # 平面形状（shape_json）
      :shape_tl_r, :shape_tr_r, :shape_bl_r, :shape_br_r,
      # コーナー加工（corner_proc_json）
      :corner_tl_code, :corner_tr_code, :corner_bl_code, :corner_br_code,
      :corner_tl_r,    :corner_tr_r,    :corner_bl_r,    :corner_br_r,
      :corner_tl_dx,   :corner_tr_dx,   :corner_bl_dx,   :corner_br_dx,
      :corner_tl_dy,   :corner_tr_dy,   :corner_bl_dy,   :corner_br_dy,
      # 丸穴（hole_json）
      :hole_tl_flag, :hole_tr_flag, :hole_bl_flag, :hole_br_flag,
      :hole_tl_dia_code, :hole_tr_dia_code, :hole_bl_dia_code, :hole_br_dia_code,
      :hole_tl_dia_mm,   :hole_tr_dia_mm,   :hole_bl_dia_mm,   :hole_br_dia_mm,
      :hole_tl_dx,       :hole_tr_dx,       :hole_bl_dx,       :hole_br_dx,
      :hole_tl_dy,       :hole_tr_dy,       :hole_bl_dy,       :hole_br_dy,
      # 四角穴（sqhole_json）
      :sqhole_tl_flag, :sqhole_tr_flag, :sqhole_bl_flag, :sqhole_br_flag,
      :sqhole_tl_dx,   :sqhole_tr_dx,   :sqhole_bl_dx,   :sqhole_br_dx,
      :sqhole_tl_dy,   :sqhole_tr_dy,   :sqhole_bl_dy,   :sqhole_br_dy,
      :sqhole_tl_h,    :sqhole_tr_h,    :sqhole_bl_h,    :sqhole_br_h,
      :sqhole_tl_w,    :sqhole_tr_w,    :sqhole_bl_w,    :sqhole_br_w,
      # 断面加工（edge_json）
      :edge_tl_code, :edge_t_code, :edge_tr_code,
      :edge_l_code,                :edge_r_code,
      :edge_bl_code, :edge_b_code, :edge_br_code,
      # 塗装加工（paint_json）
      :paint_surface_code, :paint_color_code, :grain_finish_code, :gloss_code
    )
  end

end
