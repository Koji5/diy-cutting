# frozen_string_literal: true

# HoleParamExtractor
# ------------------------------------------------------------
# ctx (Stimulus buildContext) から丸穴 / 四角穴パラメータを抽出し，
# GeometryChecks が扱える形式 [{ shape:, cx:, cy:, ... }, ...] へ変換する．
# ※ 大文字識別子 (L, W) は Ruby では定数扱いになるため
#    すべて小文字 (l, w) のローカル変数へ置き換え済み。
# ------------------------------------------------------------
module HoleParamExtractor
  module_function

  POSITIONS = %w[tl tr bl br].freeze

  # ----------------------------------------------------------
  # Public: ctx → holes 配列
  # ----------------------------------------------------------
  def build_holes(ctx)
    ctx = ctx.to_h.symbolize_keys
    l, w = part_dimensions(ctx)

    holes = []
    POSITIONS.each do |pos|
      # ==== 丸穴 ============================================
      if truthy?(ctx["hole_#{pos}_flag".to_sym])
        dx = ctx["hole_#{pos}_dx".to_sym].to_f
        dy = ctx["hole_#{pos}_dy".to_sym].to_f
        if (dia = circle_diameter(ctx, pos))
          cx, cy = circle_center(pos, dx, dy, l, w)
          holes << { shape: :circle, cx: cx, cy: cy, r: dia / 2.0 }
        end
      end

      # ==== 四角穴 ==========================================
      if truthy?(ctx["sqhole_#{pos}_flag".to_sym])
        dx = ctx["sqhole_#{pos}_dx".to_sym].to_f
        dy = ctx["sqhole_#{pos}_dy".to_sym].to_f
        w_mm = ctx["sqhole_#{pos}_w".to_sym]&.to_f
        h_mm = ctx["sqhole_#{pos}_h".to_sym]&.to_f
        if w_mm&.positive? && h_mm&.positive?
          cx, cy = rect_center(pos, dx, dy, w_mm, h_mm, l, w)
          holes << { shape: :rect, cx: cx, cy: cy, w: w_mm, h: h_mm }
        end
      end
    end

    holes
  end

  # ----------------------------------------------------------
  # 円穴直径 (mm) — すでに数値で渡ってくる前提
  # ----------------------------------------------------------
  def circle_diameter(ctx, pos)
    val = ctx["hole_#{pos}_dia_mm_or_code".to_sym]
    return nil if val.blank?
    num = val.to_f
    num.positive? ? num : nil
  end

  # ----------------------------------------------------------
  # 寸法取得 (mm) 返り値は [length, width]
  # ----------------------------------------------------------
  def part_dimensions(ctx)
    l = ctx[:length_mm]
    w = ctx[:width1_mm]
    raise ArgumentError, 'ctx に length_mm / width1_mm が不足しています' unless l && w
    [l.to_f, w.to_f]
  end

  # ----------------------------------------------------------
  # 中心計算
  # ----------------------------------------------------------
  def circle_center(pos, dx, dy, l, w)
    case pos
    when 'tl' then [dx,           w - dy]
    when 'tr' then [l - dx,       w - dy]
    when 'bl' then [dx,           dy]
    when 'br' then [l - dx,       dy]
    else [dx, dy]
    end.map(&:to_f)
  end

  def rect_center(pos, dx, dy, rw, rh, l, w)
    case pos
    when 'tl' then [dx + rw / 2.0,    w - dy - rh / 2.0]
    when 'tr' then [l - dx - rw / 2.0, w - dy - rh / 2.0]
    when 'bl' then [dx + rw / 2.0,    dy + rh / 2.0]
    when 'br' then [l - dx - rw / 2.0, dy + rh / 2.0]
    else [dx + rw / 2.0, dy + rh / 2.0]
    end.map(&:to_f)
  end

  # ----------------------------------------------------------
  # truthy? helper
  # ----------------------------------------------------------
  def truthy?(val)
    case val
    when String then %w[true 1].include?(val)
    else !!val
    end
  end
end
