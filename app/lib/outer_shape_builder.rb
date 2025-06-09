# frozen_string_literal: true

# app/lib/outer_shape_builder.rb
# --------------------------------------------------------------
# 外形ポリラインを生成するユーティリティ。
# Path.new(x0, y0).line_to(...).arc(...).close の命令型 DSL で
# [[x,y], ...] 時計回り点列を返す。四隅の処理は corner_*_code
# に応じて NONE / ROUND_R / INROUND / CHAMFER / BEVEL を実装。
#
# shape_code は 3 パターンのみ︰
#   1. "TRI_EQ"   … 正三角形（頂点が上）
#   2. "NICHE"    … 長方形 + 上側外向き円弧
#   3. その他      … 矩形 (RECT 相当、角形状可変）
#
# ※ ctx は CtxNormalizer.call で正規化済みのハッシュを想定。
# --------------------------------------------------------------
module OuterShapeBuilder
  SEG_DEG = 5.0                            # 円弧分割角度(度)
  RAD     = Math::PI / 180.0

  #============================================================
  # 内部 DSL ---------------------------------------------------
  #============================================================
  class Path
    def initialize(x0, y0)
      @pts = [[x0, y0]]
      @cur = [x0, y0]
    end

    # 直線セグメントを追加
    def line_to(x, y)
      @pts << [x, y]
      @cur = [x, y]
      self
    end

    # 円弧を分割して追加（a0→a1, 角度はラジアン）
    def arc(cx, cy, r, a0, a1)
      sweep = a1 - a0
      segs  = [(sweep.abs / (SEG_DEG * RAD)).ceil, 1].max
      1.upto(segs) do |i|
        t = a0 + sweep * i / segs
        @pts << [cx + r * Math.cos(t), cy + r * Math.sin(t)]
      end
      @cur = @pts.last
      self
    end

    # 始点に戻り点列を返す
    def close
      @pts << @pts.first unless @pts.first == @pts.last
      @pts
    end
  end

  #============================================================
  # エントリポイント ------------------------------------------
  #============================================================
  module_function

  # @param ctx [Hash] outer_ctx (CtxNormalizer で正規化済み)
  # @return [Array<Array<Float>>] 外周座標列 (時計回り)
  def build_outer_path(ctx)
    case ctx[:shape_code]
    when "TRI_EQ"  then build_equilateral(ctx)
    when "NICHE"   then build_niche(ctx)
    else                  build_rect(ctx)          # デフォルトは可変矩形
    end
  end

  #============================================================
  # 各 shape 実装 ---------------------------------------------
  #============================================================
  # 1. 可変矩形 (corner_*_code に応じて処理)
  def build_rect(ctx)
    l = ctx[:length_mm].to_f
    w = ctx[:width1_mm].to_f

    # 角パラメータをローカル変数へ
    r_tl, r_tr = ctx.values_at(:corner_tl_r, :corner_tr_r).map(&:to_f)
    r_bl, r_br = ctx.values_at(:corner_bl_r, :corner_br_r).map(&:to_f)
    dx_tl, dx_tr, dx_bl, dx_br = ctx.values_at(:corner_tl_dx, :corner_tr_dx, :corner_bl_dx, :corner_br_dx).map(&:to_f)
    dy_tl, dy_tr, dy_bl, dy_br = ctx.values_at(:corner_tl_dy, :corner_tr_dy, :corner_bl_dy, :corner_br_dy).map(&:to_f)

    code_tl, code_tr = ctx.values_at(:corner_tl_code, :corner_tr_code)
    code_bl, code_br = ctx.values_at(:corner_bl_code, :corner_br_code)

    # "NONE" の場合は半径を強制ゼロにしておく
    r_tl = 0.0 if code_tl == "NONE"
    r_tr = 0.0 if code_tr == "NONE"
    r_bl = 0.0 if code_bl == "NONE"
    r_br = 0.0 if code_br == "NONE"

    #----------------------------------
    # 1) スタート（左下始点）
    #----------------------------------
    path = case code_bl
           when "ROUND_R", "INROUND", "NONE" then Path.new(r_bl, 0)
           when "CHAMFER", "BEVEL" then Path.new(dx_bl, 0)
           else Path.new(0, 0)
           end

    #----------------------------------
    # 2) 左下角処理
    #----------------------------------
    case code_bl
    when "NONE", "ROUND_R"
      path.arc(r_bl, r_bl, r_bl, -Math::PI / 2, Math::PI) unless r_bl.zero?
    when "INROUND"
      path.arc(0, 0, r_bl, 0, Math::PI / 2) unless r_bl.zero?
    when "CHAMFER"
      path.line_to(dx_bl, dy_bl).line_to(0, dy_bl)
    when "BEVEL"
      path.line_to(0, dy_bl)
    end

    #----------------------------------
    # 3) 左辺
    #----------------------------------
    y_left_target = if ["NONE", "ROUND_R", "INROUND"].include?(code_tl)
                      w - r_tl
                    else
                      w - dy_tl
                    end
    path.line_to(0, y_left_target)

    #----------------------------------
    # 4) 左上角処理
    #----------------------------------
    case code_tl
    when "NONE", "ROUND_R"
      path.arc(r_tl, w - r_tl, r_tl, Math::PI, Math::PI / 2) unless r_tl.zero?
    when "INROUND"
      path.arc(0, w, r_tl, -Math::PI / 2, 0) unless r_tl.zero?
    when "CHAMFER"
      path.line_to(dx_tl, w - dy_tl).line_to(dx_tl, w)
    when "BEVEL"
      path.line_to(dx_tl, w)
    end

    #----------------------------------
    # 5) 上辺
    #----------------------------------
    x_top_target = if ["NONE", "ROUND_R", "INROUND"].include?(code_tr)
                     l - r_tr
                   else
                     l - dx_tr
                   end
    path.line_to(x_top_target, w)

    #----------------------------------
    # 6) 右上角処理
    #----------------------------------
    case code_tr
    when "NONE", "ROUND_R"
      path.arc(l - r_tr, w - r_tr, r_tr, Math::PI / 2, 0) unless r_tr.zero?
    when "INROUND"
      path.arc(l, w, r_tr, Math::PI, -Math::PI / 2) unless r_tr.zero?
    when "CHAMFER"
      path.line_to(l - dx_tr, w - dy_tr).line_to(l, w - dy_tr)
    when "BEVEL"
      path.line_to(l, w - dy_tr)
    end

    #----------------------------------
    # 7) 右辺
    #----------------------------------
    y_right_target = if ["NONE", "ROUND_R", "INROUND"].include?(code_br)
                       r_br
                     else
                       dy_br
                     end
    path.line_to(l, y_right_target)

    #----------------------------------
    # 8) 右下角処理
    #----------------------------------
    case code_br
    when "NONE", "ROUND_R"
      path.arc(l - r_br, r_br, r_br, 0, -Math::PI / 2) unless r_br.zero?
    when "INROUND"
      path.arc(l, 0, r_br, Math::PI / 2, Math::PI) unless r_br.zero?
    when "CHAMFER"
      path.line_to(l - dx_br, dy_br).line_to(l - dx_br, 0)
    when "BEVEL"
      path.line_to(l - dx_br, 0)
    end

    #----------------------------------
    # 9) 下辺 & close
    #----------------------------------
    path.close
  end

  # 2. 正三角形 (TRI_EQ)
  def build_equilateral(ctx)
    side = ctx[:width1_mm].to_f
    h    = side * Math.sqrt(3) / 2.0

    Path.new(0, 0)            # 左下始点
        .line_to(side / 2.0, h)     # 上頂点
        .line_to(side, 0)      # 右下
        .close
  end

  # 3. NICHE  (矩形 + 上側外向き円弧)
  #  ┌─ r_tl/r_tr は無視（矩形部上端は W1 まで）───────────────┐
  #  ↓                                                   ↑
  #  └───── r_bl / r_br / CHAMFER / BEVEL / INROUND … は build_rect と同じ処理
  def build_niche(ctx)
    l  = ctx[:length_mm].to_f      # L  : 全長
    w1 = ctx[:width1_mm].to_f      # W1 : 矩形部高さ
    w2 = ctx[:width2_mm].to_f      # W2 : 全高 (円弧頂点)
  
    sag  = w2 - w1                 # 矢高 (張り出し)
    return build_rect(ctx) if sag <= 0        # 張り出しゼロなら普通の矩形
  
    r     = (l**2) / (8.0 * sag) + sag / 2.0  # 円弧半径
    cx    = l / 2.0                           # 円心 X
    cy    = w2 - r                            # 円心 Y
    theta = 2.0 * Math.asin(l / (2.0 * r))    # 円弧中心角
  
    # ---------- 角パラメータ ----------
    r_bl, r_br = ctx.values_at(:corner_bl_r, :corner_br_r).map(&:to_f)
    dx_bl, dx_br = ctx.values_at(:corner_bl_dx, :corner_br_dx).map(&:to_f)
    dy_bl, dy_br = ctx.values_at(:corner_bl_dy, :corner_br_dy).map(&:to_f)
    code_bl, code_br = ctx.values_at(:corner_bl_code, :corner_br_code)

    # "NONE" の場合は半径を強制ゼロにしておく 
    r_bl = 0.0 if code_bl == "NONE"
    r_br = 0.0 if code_br == "NONE"

    # --- 1) スタート（左下） ----------------
    path = case code_bl
           when "NONE", "ROUND_R", "INROUND" then Path.new(r_bl, 0)
           when "CHAMFER", "BEVEL"           then Path.new(dx_bl, 0)
           else Path.new(0, 0)
           end
  
    # --- 2) 左下角 --------------------------
    case code_bl
    when "NONE", "ROUND_R"
      path.arc(r_bl, r_bl, r_bl, -Math::PI / 2, Math::PI) unless r_bl.zero?
    when "INROUND"
      path.arc(0, 0, r_bl, 0, Math::PI / 2) unless r_bl.zero?
    when "CHAMFER"
      path.line_to(dx_bl, dy_bl).line_to(0, dy_bl)
    when "BEVEL"
      path.line_to(0, dy_bl)
    end
  
    # --- 3) 左辺 → 矩形部上端 ----------------
    path.line_to(0, w1)
  
    # --- 4) 上側外向き円弧 --------------------
    a0 =  Math::PI / 2 + theta / 2.0   # 左端側（時計回り開始）
    a1 =  Math::PI / 2 - theta / 2.0   # 右端側
    path.arc(cx, cy, r, a0, a1)        # 時計回りで描画
  
    # --- 5) 右辺 → 右下加工開始 --------------
    y_right_target = if %w[NONE ROUND_R INROUND].include?(code_br)
                       r_br
                     else
                       dy_br
                     end
    path.line_to(l, y_right_target)
  
    # --- 6) 右下角 ---------------------------
    case code_br
    when "NONE", "ROUND_R"
      path.arc(l - r_br, r_br, r_br, 0, -Math::PI / 2) unless r_br.zero?
    when "INROUND"
      path.arc(l, 0, r_br, Math::PI / 2, Math::PI) unless r_br.zero?
    when "CHAMFER"
      path.line_to(l - dx_br, dy_br).line_to(l - dx_br, 0)
    when "BEVEL"
      path.line_to(l - dx_br, 0)
    end
  
    # --- 7) 下辺 & close ---------------------
    path.close
  end

end
