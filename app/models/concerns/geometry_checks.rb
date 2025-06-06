# app/models/concerns/geometry_checks.rb
# --------------------------------------------------------------
# 丸穴・四角穴の『外周はみ出し』『他穴との重なり』をサーバー側で検証。
#   - SAFE_EDGE / SAFE_OVERLAP は config/geometry.yml で一元管理
#   - DimensionValidator から include され、check_geometry(record, ctx) を呼ぶ
# ※ 現状は “外周 = 矩形 (長さ×巾1)” を前提。NICHE/三角などは今後拡張。
# --------------------------------------------------------------
module GeometryChecks
  extend ActiveSupport::Concern

  SAFE = Rails.application.config.x.geometry.symbolize_keys
  SAFE_EDGE     = SAFE[:safe_edge_mm].to_f
  SAFE_OVERLAP  = SAFE[:safe_overlap_mm].to_f

  # ============================================================
  # Public: DimensionValidator から呼ばれるメイン関数
  # ------------------------------------------------------------
  def check_geometry(record, ctx)
    # ctx から外周ポリラインを生成（NICHE/CIRC 等対応）
    outer = OuterShapeBuilder.build_outer_path(ctx)

    # ───── 外形パラメータ（穴座標算出に使用）─────
    l = record.length_mm.to_f
    w = record.width1_mm.to_f

    # ───── 丸穴を抽出 ─────
    holes_round = %i[tl tr bl br].filter_map do |p|
      h = record.public_send("hole_#{p}") || next
      next unless h["flag"]

      dx  = h["dx"].to_f
      dy  = h["dy"].to_f
      dia = h["dia_mm"]&.to_f || HOLE_DIAMETERS[h["dia"]]
      # ---- corner-relative dx / dy → 外形座標系へ変換 -------------
      cx, cy =
        case p
        when :tl then [dx,             w - dy]      # 左上
        when :tr then [l - dx,         w - dy]      # 右上
        when :bl then [dx,             dy]          # 左下
        when :br then [l - dx,         dy]          # 右下
        end

      {
        type: :R,
        pos:  p,
        cx:   cx,
        cy:   cy,
        r:    dia.to_f / 2
      }
    end

    # ───── 四角穴を抽出 ─────
    holes_square = %i[tl tr bl br].filter_map do |p|
      h = record.public_send("sqhole_#{p}") || next
      next unless h["flag"]

      dx, dy = h.values_at("dx", "dy").map(&:to_f)
      hh, ww = h.values_at("h", "w").map(&:to_f)
      next unless dx && dy && hh.positive? && ww.positive?

      cx = case p
            when :tl then dx + ww / 2
            when :tr then l - dx - ww / 2
            when :bl then dx + ww / 2
            when :br then l - dx - ww / 2
          end
      cy = case p
            when :tl then w - dy - hh / 2
            when :tr then w - dy - hh / 2
            when :bl then dy + hh / 2
            when :br then dy + hh / 2
          end
      {
        type: :S, pos: p, cx: cx, cy: cy, w: ww, h: hh
      }
    end

    # ctx も渡して INROUND 判定に使う
    check_edge_poly(record, holes_round, holes_square, outer, ctx)
    check_overlap(record, holes_round, holes_square)
  end

  private

  # ------------------------------------------------------------
  # 1) 外周からの安全距離チェック（ポリライン版）
  #     + INROUND くぼみとの距離チェック
  # ------------------------------------------------------------
  def check_edge_poly(record, rounds, squares, outer, ctx)
    l = record.length_mm.to_f
    w = record.width1_mm.to_f

    # --- (a) ポリラインとの距離 -----------------------------------
    rounds.each do |h|
      unless inside_round_poly?(outer, h, SAFE_EDGE)
        record.errors.add(:base, "丸穴は外周から#{SAFE_EDGE}mm以上離してください")
      end
    end

    squares.each do |h|
      unless inside_rect_poly?(outer, h, SAFE_EDGE)
        record.errors.add(:base, "四角穴は外周から#{SAFE_EDGE}mm以上離してください")
      end
    end

    # --- (b) INROUND くぼみ円弧との距離 --------------------------
    (ctx[:corners] || {}).each do |pos, cfg|
      next unless cfg[:code] == "INROUND" && cfg[:r].to_f.positive?

      r_in = cfg[:r].to_f
      cx, cy =
        case pos
        when :tl then [ r_in,                     w - r_in ]
        when :tr then [ l - r_in,                 w - r_in ]
        when :br then [ l - r_in,                 r_in ]
        when :bl then [ r_in,                     r_in ]
        end

      rounds.each do |h|
        dist  = Math.hypot(h[:cx] - cx, h[:cy] - cy)
        limit = r_in - SAFE_EDGE - h[:r]
        if dist < limit
          record.errors.add(:base, "丸穴は外周から#{SAFE_EDGE}mm以上離してください")
          break
        end
      end
    end

  end

  # ------------------------------------------------------------
  # 2) 穴どうしの安全距離チェック
  # ------------------------------------------------------------
  def check_overlap(record, rounds, squares)
    holes = rounds + squares
    holes.combination(2) do |a, b|
      overlapped = case [a[:type], b[:type]]
                   when %i[R R] then overlap_round_round?(a, b)
                   when %i[S S] then overlap_rect_rect?(a, b)
                   else              overlap_round_rect?(a[:type] == :R ? a : b,
                                                         a[:type] == :S ? a : b)
                   end
      record.errors.add(:base, "穴同士は#{SAFE_OVERLAP * 2}mm以上離してください") if overlapped
    end
  end

  # ------------------------------------------------------------
  # 3) 幾何ヘルパ
  # ------------------------------------------------------------
  def overlap_round_round?(a, b)
    dx = a[:cx] - b[:cx]
    dy = a[:cy] - b[:cy]
    r  = a[:r] + b[:r] + SAFE_OVERLAP * 2
    dx * dx + dy * dy < r * r
  end

  def overlap_rect_rect?(a, b)
    ax1 = a[:cx] - a[:w] / 2 - SAFE_OVERLAP
    ax2 = a[:cx] + a[:w] / 2 + SAFE_OVERLAP
    ay1 = a[:cy] - a[:h] / 2 - SAFE_OVERLAP
    ay2 = a[:cy] + a[:h] / 2 + SAFE_OVERLAP

    bx1 = b[:cx] - b[:w] / 2 - SAFE_OVERLAP
    bx2 = b[:cx] + b[:w] / 2 + SAFE_OVERLAP
    by1 = b[:cy] - b[:h] / 2 - SAFE_OVERLAP
    by2 = b[:cy] + b[:h] / 2 + SAFE_OVERLAP

    ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1
  end

  def overlap_round_rect?(circ, rect)
    dx = [(circ[:cx] - rect[:cx]).abs - rect[:w] / 2 - SAFE_OVERLAP, 0].max
    dy = [(circ[:cy] - rect[:cy]).abs - rect[:h] / 2 - SAFE_OVERLAP, 0].max
    dx * dx + dy * dy < (circ[:r] + SAFE_OVERLAP)**2
  end

  # ------------------------------------------------------------
  # 4) 外周ポリライン内判定ヘルパ
  # ------------------------------------------------------------
  def inside_round_poly?(poly, circ, margin = 0)
    r = circ[:r] + margin
    16.times.all? do |i|
      a = 2 * Math::PI * i / 16
      x = circ[:cx] + r * Math.cos(a)
      y = circ[:cy] + r * Math.sin(a)
      PointInPolygon.inside?(poly, x, y)
    end
  end

  def inside_rect_poly?(poly, rect, margin = 0)
    dx = rect[:w] / 2 + margin
    dy = rect[:h] / 2 + margin
    [
      [ rect[:cx] - dx, rect[:cy] - dy ],
      [ rect[:cx] + dx, rect[:cy] - dy ],
      [ rect[:cx] + dx, rect[:cy] + dy ],
      [ rect[:cx] - dx, rect[:cy] + dy ]
    ].all? { |x, y| PointInPolygon.inside?(poly, x, y) }
  end

end
