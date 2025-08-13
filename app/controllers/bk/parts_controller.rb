class PartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_part, only: %i[edit update]

  # ───────────────────────
  # 一覧 (SID-PR-100)
  # ───────────────────────
  def index
    # 今は全件。次フェーズで検索・並び替えを入れる
    @parts = Current.account.parts
              .kept
              .includes(:origin_owner, thumbnail_attachment: :blob)
              .order(updated_at: :desc)
    # affiliate の場合のみ “オリジナル作成者” を表示するため
    @show_owner = Current.account&.has_role?(:affiliate)
    render_flash_and_replace_main(
        template: "parts/index",
        assigns: {
          parts: @parts,
          show_owner: @show_owner
        }
    )
  end

  def show
    @part = Part.find(params[:id])
    assigns = load_masters_hash
    assigns[:part] = @part
    render_flash_and_replace_main(
        template: "parts/show",
        assigns: assigns
    )
  end

  def show_modal
    load_masters
    @part = Part.find(params[:id])
    render layout: (turbo_frame_request? ? false : "application")
  end

  def new
    @part = Part.new
    render_flash_and_replace_main(
        template: "parts/new",
        assigns: load_masters_hash.merge(load_rules_hash).merge(part: @part)
    )
  end

  def create
    @part = Current.account.parts.build(basic_part_params)   # 基本カラム
    @part.material_category_code ||= "WOOD"
    #   ↑ フォームで送られていなければ強制的に WOOD をセット
    #   （将来カテゴリ選択式にしたときはこの行を削除 or 条件分岐）

    if @part.save
      render_flash_and_replace_main(
        template: "parts/show",
        assigns: load_masters_hash.merge(part: @part),
        message: "部品を登録しました。",
        type: :notice
      )
    else
      flash[:alert] = @part.errors.full_messages
      render_flash_and_replace(
          flash: flash
      )
    end
  end

  def edit
    render_flash_and_replace_main(
      template: "parts/edit",
      assigns: load_masters_hash.merge(load_rules_hash).merge(part: @part)
    )
  end

  def update
    @part.material_category_code ||= "WOOD"
    #   ↑ フォームで送られていなければ強制的に WOOD をセット
    #   （将来カテゴリ選択式にしたときはこの行を削除 or 条件分岐）
    if @part.update(basic_part_params)
      render_flash_and_replace_main(
        template: "parts/show",
        assigns: load_masters_hash.merge(load_rules_hash).merge(part: @part),
        message: "部品を更新しました。",
        type: :notice
      )
    else
      flash[:alert] = @part.errors.full_messages
      render_flash_and_replace_main(
        flash: flash
      )
    end
  end

  def destroy
    @part = Part.kept.find(params[:id])
    @part.discard!
    flash[:notice] = Array(flash[:notice]) << "部品「#{@part.name}」を削除しました。"
    render_flash_and_remove(dom_id: @part, flash: flash)
  end

  def inline_detail
    load_masters
    @part = Part.find(params[:id])
    render partial: "parts/inline_detail", locals: { part: @part }
  end

  private

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
  end

  #def load_rules
  #  # --- グローバルルール -----------------------------------------
  #  @global_dim_rule = GLOBAL_DIM_RULE

  #  # ---------- Stimulus へ渡す JSON まとめ ---------- #
  #  @shape_rules = {
  #    shape:  @shapes.index_by(&:code).transform_values(&:allow_shape_json),
  #    corner: @shapes.index_by(&:code).transform_values(&:allow_corner_json),
  #    edge:   @shapes.index_by(&:code).transform_values(&:allow_edge_json)
  #  }.to_json

  #  @corner_proc_rules = @corner_processes
  #                         .index_by(&:code)
  #                         .transform_values(&:allow_corner_proc_json)
  #                         .to_json

  #  @paint_type_rules  = @paint_types
  #                         .index_by(&:code)
  #                         .transform_values(&:allow_paint_json)
  #                         .to_json
  #end

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
      :paint_surface_code, :paint_color_code, :grain_finish_code, :gloss_code,
      # サムネイル画像
      :thumbnail_data, :camera_state_json
    )
  end

  def load_masters_hash
    {
      material_categories: MCategory.order(:code),
      materials:           MMaterial.order(:code),
      shapes:              MShape.order(:code),
      edge_processes:      MEdgeProcess.order(:code),
      corner_processes:    MCornerProcess.order(:code),
      hole_diameters:      MHoleDiameter.order(:hole_mm),
      paint_types:         MPaintType.order(:code),
      paint_surfaces:      MPaintSurface.order(:code),
      paint_colors:        MPaintColor.order(:code),
      grain_finishes:      MGrainFinish.order(:code),
      glosses:             MGloss.order(:code)
    }
  end

  def load_rules_hash
    shapes = MShape.order(:code).index_by(&:code)
    corner_processes = MCornerProcess.order(:code).index_by(&:code)
    paint_types = MPaintType.order(:code).index_by(&:code)

    {
      global_dim_rule: GLOBAL_DIM_RULE,
      shape_rules: {
        shape:  shapes.transform_values(&:allow_shape_json),
        corner: shapes.transform_values(&:allow_corner_json),
        edge:   shapes.transform_values(&:allow_edge_json)
      }.to_json,
      corner_proc_rules: corner_processes.transform_values(&:allow_corner_proc_json).to_json,
      paint_type_rules:  paint_types.transform_values(&:allow_paint_json).to_json
    }
  end

  def set_part
    @part = Current.account.parts.kept.find(params[:id])
  end

end
