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

    # ─ JSON 列を組み立て ─────────────────────────
    @part.material_category_code ||= "WOOD"
    #   ↑ フォームで送られていなければ強制的に WOOD をセット
    #   （将来カテゴリ選択式にしたときはこの行を削除 or 条件分岐）
    @part.shape_json        = build_shape_json
    @part.corner_proc_json  = build_corner_json
    @part.hole_json         = build_hole_json
    @part.sqhole_json       = build_sqhole_json
    @part.edge_json         = build_edge_json
    @part.paint_json        = build_paint_json

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

  def load_masters
    @material_categories = MCategory.order(:code)
    @materials           = MMaterial.order(:code)
    @shapes              = MShape.order(:code)
    @paint_types         = MPaintType.order(:code)
  end

    # ───────── 基本項目 (テーブルの直接カラム) ─────────
  def basic_part_params
    params.require(:part).permit(
      :name, :material_category_code, :material_code, :shape_code,
      :paint_type_code, :thickness_mm, :width1_mm, :width2_mm,
      :length_mm, :note
    )
  end

  # ───────── shape_json (面取り半径など) ─────────
  def build_shape_json
    keys = %w[tl tr bl br]
    keys.filter_map do |k|
      r = params.dig(:part, "shape_#{k}_r")
      r.present? ? [k, r.to_f] : nil
    end.to_h
  end

  # ───────── corner_proc_json ─────────
  def build_corner_json
    %w[tl tr bl br].index_with do |k|
      code = params.dig(:part, "corner_#{k}_code")
      next if code.blank? || code == "NONE"

      h = { proc: code }
      %w[r dx dy].each do |p|
        v = params.dig(:part, "corner_#{k}_#{p}")
        h[p.to_sym] = v.to_f if v.present?
      end
      h
    end.compact
  end

  # ───────── hole_json (丸穴) ─────────
  def build_hole_json
    %w[tl tr bl br].index_with do |k|
      flag = params.dig(:part, "hole_#{k}_flag") == "1"
      next unless flag

      {
        flag: true,
        dy:   to_f_or_nil(params.dig(:part, "hole_#{k}_dy")),
        dx:   to_f_or_nil(params.dig(:part, "hole_#{k}_dx")),
        dia:  params.dig(:part, "hole_#{k}_dia_code").presence,
        dia_mm: to_f_or_nil(params.dig(:part, "hole_#{k}_dia_mm"))
      }.compact
    end.compact
  end

  # ───────── sqhole_json (四角穴) ─────────
  def build_sqhole_json
    %w[tl tr bl br].index_with do |k|
      flag = params.dig(:part, "sqhole_#{k}_flag") == "1"
      next unless flag

      {
        flag: true,
        dy: to_f_or_nil(params.dig(:part, "sqhole_#{k}_dy")),
        dx: to_f_or_nil(params.dig(:part, "sqhole_#{k}_dx")),
        h:  to_f_or_nil(params.dig(:part, "sqhole_#{k}_h")),
        w:  to_f_or_nil(params.dig(:part, "sqhole_#{k}_w"))
      }.compact
    end.compact
  end

  # ───────── edge_json (断面加工) ─────────
  def build_edge_json
    %w[tl t tr l r bl b br].map do |k|
      code = params.dig(:part, "edge_#{k}_code")
      code.present? && code != "NONE" ? [k, code] : nil
    end.compact.to_h
  end

  # ───────── paint_json (塗装詳細) ─────────
  def build_paint_json
    {
      surface: params.dig(:part, :paint_surface_code).presence,
      color:   params.dig(:part, :paint_color_code).presence,
      grain:   params.dig(:part, :grain_finish_code).presence,
      gloss:   params.dig(:part, :gloss_code).presence
    }.compact
  end

  # ───────── helper ─────────
  def to_f_or_nil(v)
    v.present? ? v.to_f : nil
  end
end
