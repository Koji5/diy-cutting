# app/lib/outer_shape_builder.rb
# -----------------------------------------------------------------------------
# フロント側 shape_builders.js に相当する “外周ポリライン” 生成ユーティリティ。
#   - ctx は DimensionValidator#build_context で組み立てられたハッシュを渡す。
#   - 戻り値は [[x1,y1], [x2,y2], ...] の CW 順ポリライン（左下原点）。
#   - 曲線（円弧・円板）は等角分割でポリライン化する。
# -----------------------------------------------------------------------------
module OuterShapeBuilder
  extend self

  # ------------------------------------------
  # 定数
  # ------------------------------------------
  SEG = 128        # 曲線を等角分割する最小セグメント数

  # =========================================================================
  # Public: ctx → 外周ポリライン
  # =========================================================================
  def build_outer_path(ctx)
    case ctx[:shapeCode] || ctx[:shape_code]
    when "NICHE"   then build_niche(ctx)
    when "TRI_EQ"  then build_equilateral(ctx)
    when "CIRC"    then build_circle(ctx)
    when "SEMI"    then build_semicircle(ctx)
    else                  build_rect_corners(ctx)
    end
  end

  # -------------------------------------------------------------------------
  # 1) 矩形 + 角加工 (ROUND_R / INROUND / CHAMFER / BEVEL)
  # -------------------------------------------------------------------------
  def build_rect_corners(ctx)
    l = ctx[:length_mm].to_f
    w = ctx[:width1_mm].to_f
    # ctx[:corners] は { proc: "...", r:, dx:, dy: } 形式なので
    # :code が無ければ :proc をコピーして正規化する
    c = (ctx[:corners] || {}).transform_values do |h|
      h = h.symbolize_keys
      h[:code] ||= h[:proc]
      h
    end

    # デフォルト値
    %i[tl tr br bl].each { |k| c[k] ||= { code: "NONE", r: 0, dx: 0, dy: 0 } }

    poly = []

    # 1) ── BL（左下）スタート ──────────────────────
    poly << [offset_x(:bl, c[:bl]), 0]
    poly.concat corner_path(:bl, 0, 0, c[:bl])

    # 2) ── 左辺 → TL ─────────────────────────────
    poly << [0, w - offset_y(:tl, c[:tl])]
    poly.concat corner_path(:tl, 0, w, c[:tl])

    # 3) ── 上辺 → TR ─────────────────────────────
    poly << [l - offset_x(:tr, c[:tr]), w]
    poly.concat corner_path(:tr, l, w, c[:tr])

    # 4) ── 右辺 → BR ────────────────────────────
    poly << [l, offset_y(:br, c[:br])]
    poly.concat corner_path(:br, l, 0, c[:br])

    # 5) ── 下辺（始点へ戻る）─────────────────────────
    start_x = offset_x(:bl, c[:bl])
    poly << [start_x, 0] unless poly.last == [start_x, 0]
    poly
  end

  # ===== Helper: 各隅オフセット量 ===========================================
  def offset_x(_pos, cfg)
    case cfg[:code]
    when "CHAMFER", "BEVEL"  then cfg[:dx].to_f
    when "ROUND_R"           then cfg[:r].to_f   # ← 外側Ｒだけオフセット
    else 0
    end
  end

  def offset_y(_pos, cfg)
    case cfg[:code]
    when "CHAMFER", "BEVEL"  then cfg[:dy].to_f
    when "ROUND_R"           then cfg[:r].to_f
    else 0
    end
  end

  # ===== Helper: 角のパス生成 (戻り値: [ [x,y], … ]) =======================
  SEG_QUAD = 16   # 1/4 円分割数

  def corner_path(pos, ox, oy, cfg)
    case cfg[:code]
    # ROUND_R : 外側フチ ⇒ 時計回り
    # INROUND : くぼみ   ⇒ 反時計回り
    when "ROUND_R"    then arc(pos, ox, oy, cfg[:r].to_f, cw: true)
    when "INROUND"    then arc(pos, ox, oy, cfg[:r].to_f, cw: false)
    when "CHAMFER"    then chamfer(pos, ox, oy, cfg[:dx].to_f, cfg[:dy].to_f)
    when "BEVEL"      then bevel(pos, ox, oy, cfg[:dx].to_f, cfg[:dy].to_f)
    else []
    end
  end

  # ----- 外／内 丸 (1/4 円) -----------------------------------------------
  def arc(pos, ox, oy, r, cw:)
    return [] if r.zero?

    # ── 1) 頂点から (±r, ±r) へ中心をオフセット ──
    dir = {
      tl: [ 1, -1],
      tr: [-1, -1],
      br: [-1,  1],
      bl: [ 1,  1]
    }[pos]
    cx = ox + dir[0] * r
    cy = oy + dir[1] * r

    # ── 2) 角度範囲と向き ──
    a0   = { tl: Math::PI, tr: Math::PI/2, br: 0, bl: -Math::PI/2 }[pos]
    step = (Math::PI/2) / SEG_QUAD * (cw ? -1 : 1)

    # ── 3) 分割点を生成 ──
    (1..SEG_QUAD).map do |i|
      a = a0 + step * i
      [cx + r * Math.cos(a), cy + r * Math.sin(a)]
    end
  end

  # ----- CHAMFER (dx,dy) ---------------------------------------------------
  def chamfer(pos, ox, oy, dx, dy)
    case pos
    when :tl then [[dx, oy],           [ox, oy - dy]]
    when :tr then [[ox - dx, oy],      [ox, oy - dy]]
    when :br then [[ox - dx, oy],      [ox, dy]]
    when :bl then [[dx, oy],           [ox, dy]]
    end
  end

  # ----- BEVEL (dx or dy の片側) ------------------------------------------
  def bevel(pos, ox, oy, dx, dy)
    case pos
    when :tl then [[dx, oy]]
    when :tr then [[ox - dx, oy]]
    when :br then [[ox - dx, dy]]
    when :bl then [[dx, dy]]
    end
  end

  # -------------------------------------------------------------------------
  # 2) NICHE 形状（矩形 + 上部円弧）
  # -------------------------------------------------------------------------
  def build_niche(ctx)
    l, w1, w2 = ctx.values_at(:length_mm, :width1_mm, :width2_mm).map(&:to_f)
    sag  = w2 - w1
    return build_rect_corners(ctx) if sag <= 0

    r   = (l ** 2) / (8.0 * sag) + sag / 2.0
    cx  = l / 2.0
    cy  = w2 - r
    th  = 2 * Math.asin(l / (2 * r))

    seg = [(r * th / 4).ceil, SEG].max
    arc = (0...seg).map do |i|
      a = Math::PI / 2 + th / 2 - th * i / (seg - 1).to_f
      [cx + r * Math.cos(a), cy + r * Math.sin(a)]
    end

    [[0, 0], [0, w1]] + arc + [[l, 0]]
  end

  # -------------------------------------------------------------------------
  # 3) 正三角形 (TRI_EQ)
  # -------------------------------------------------------------------------
  def build_equilateral(ctx)
    w = ctx[:width1_mm].to_f
    l = ctx[:length_mm].to_f
    [[0, 0], [l / 2.0, w], [l, 0]]
  end

  # -------------------------------------------------------------------------
  # 4) 円板 (CIRC)
  # -------------------------------------------------------------------------
  def build_circle(ctx)
    r = ctx[:width1_mm].to_f / 2.0
    (0...SEG).map do |i|
      a = 2 * Math::PI * i / SEG
      [r + r * Math.cos(a), r + r * Math.sin(a)]
    end
  end

  # -------------------------------------------------------------------------
  # 5) 半円 (SEMI) — 下辺が直線、上部が半円
  # -------------------------------------------------------------------------
  def build_semicircle(ctx)
    r = ctx[:width1_mm].to_f
    seg = SEG / 2
    pts = [[0, 0]]
    pts += (0...seg).map do |i|
      a = Math::PI * i / (seg - 1).to_f
      [r + r * Math.cos(a), r * Math.sin(a)]
    end
    pts << [2 * r, 0]
    pts
  end

  
end
