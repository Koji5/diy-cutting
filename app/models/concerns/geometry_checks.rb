# frozen_string_literal: true

# GeometryChecks
# ------------------------------------------------------------
# DimensionValidator から呼び出されるジオメトリ検証モジュール。
# 外周ポリライン (outer) と穴リスト (holes) を検査し、
#   1. 穴が外周をはみ出していないか（SAFE_EDGE）
#   2. 穴どうしが安全マージン (SAFE_OVERLAP) を保っているか
# を確認します。
# ------------------------------------------------------------
module GeometryChecks
  extend ActiveSupport::Concern

  #============================================================
  # システム設定から安全マージンを取得
  #------------------------------------------------------------
  begin
    SAFE  = Rails.application.config.x.geometry.symbolize_keys
  rescue StandardError
    SAFE  = { safe_edge_mm: 0.0, safe_overlap_mm: 0.2 }
  end

  SAFE_EDGE    = SAFE[:safe_edge_mm].to_f      # 外周チェック用マージン
  SAFE_OVERLAP = SAFE[:safe_overlap_mm].to_f   # 穴どうしの安全マージン

  # ============================================================
  # Public: DimensionValidator から呼ばれるメイン関数
  # ------------------------------------------------------------
  def check_geometry(record, outer, holes)
    #outer = OuterShapeBuilder.build_outer_path(ctx)   # [[x,y], ...]
    #holes = HoleParamExtractor.build_holes(ctx)       # [{ shape:, ... }, ...]
    # デバッグ-----------------------------------------------------------
    #File.open("tmp/debug.svg", "w") do |f|
      # デバッグ用 SVG -------------------------------------
      #h = [ctx[:width1_mm].to_f, ctx[:width2_mm].to_f].max
      #f.puts "<svg viewBox='0 0 #{ctx[:length_mm]} #{h}' xmlns='http://www.w3.org/2000/svg'>"
      #f.puts "  <g transform='scale(1,-1) translate(0,-#{h})'>"

      # ① 外周ポリライン（赤）
      #poly_points = outer.map { |x, y| "#{x},#{y}" }.join(" ")
      #f.puts "    <polygon points='#{poly_points}' fill='none' stroke='red'/>"

      # ② 穴（黄色）— 円と矩形
      #holes.each do |hsh|
      #  case hsh[:shape]
      #  when :circle
      #    f.puts "    <circle cx='#{hsh[:cx]}' cy='#{hsh[:cy]}' r='#{hsh[:r]}' fill='none' stroke='yellow'/>"
      #  when :rect
      #    x = hsh[:cx] - hsh[:w] / 2.0
      #    y = hsh[:cy] - hsh[:h] / 2.0
      #    f.puts "    <rect x='#{x}' y='#{y}' width='#{hsh[:w]}' height='#{hsh[:h]}' fill='none' stroke='yellow'/>"
      #  end
      #end

      # SVG 終端 -------------------------------------------
      #f.puts "  </g></svg>"
    #end
    Rails.logger.debug { "OUTER: #{outer.inspect}" }
    Rails.logger.debug { "HOLES: #{holes.inspect}" }
    # -----------------------------------------------------------
    checker = HoleChecker.new(outer, holes)
    return if checker.valid?

    checker.errors.full_messages.each { |msg| record.errors.add(:base, msg) }
  end

  # ============================================================
  # 内部クラス: HoleChecker
  # ------------------------------------------------------------
  class HoleChecker
    include ActiveModel::Validations

    attr_reader :outer, :holes, :errors

    def initialize(outer_path, holes)
      @outer  = normalize_path(outer_path)
      @holes  = holes.map { |h| h.transform_keys(&:to_sym) }
      @errors = ActiveModel::Errors.new(self)
    end

    #-----------------------------------------------------------
    # ActiveModel ライク API
    #-----------------------------------------------------------
    def valid?
      errors.clear
      check_out_of_bounds
      check_overlap
      errors.blank?
    end

    def read_attribute_for_validation(attr) = send(attr)
    def self.lookup_ancestors = [self]
    def persisted? = false

    #-----------------------------------------------------------
    # 1. 外周はみ出し
    #-----------------------------------------------------------
    def check_out_of_bounds
      holes.each_with_index do |h, idx|
        inside = case h[:shape]
                  when :circle then inside_round?(h, SAFE_EDGE)
                  when :rect, :square then inside_rect?(h, SAFE_EDGE)
                  else false end
        Rails.logger.debug { "HOLE##{idx} inside? #{inside}" }
        errors.add(:base, "穴##{idx + 1} が外周をはみ出しています") unless inside
      end
    end

    #-----------------------------------------------------------
    # 2. 穴どうし重なり
    #-----------------------------------------------------------
    def check_overlap
      holes.combination(2).with_index(1) do |(a, b), i|
        overlap = case [a[:shape], b[:shape]]
                  when [:circle, :circle] then overlap_round_round?(a, b, SAFE_OVERLAP)
                  when [:rect, :rect]     then overlap_rect_rect?(a, b, SAFE_OVERLAP)
                  when [:circle, :rect]   then overlap_round_rect?(a, b, SAFE_OVERLAP)
                  when [:rect, :circle]   then overlap_round_rect?(b, a, SAFE_OVERLAP)
                  else false end
        errors.add(:base, "穴どうしが重なっています (ペア##{i})") if overlap
      end
    end

    #-----------------------------------------------------------
    # 外周内判定
    #-----------------------------------------------------------
    def inside_round?(hole, margin)
      r = hole[:r].to_f + margin
      samples_on_circle(hole[:cx], hole[:cy], r).all? { |x, y| point_in_polygon?(@outer, x, y) }
    end

    def inside_rect?(hole, margin)
      hw = hole[:w].to_f / 2 + margin
      hh = hole[:h].to_f / 2 + margin
      cx = hole[:cx]
      cy = hole[:cy]
      [ [cx - hw, cy - hh], [cx + hw, cy - hh],
        [cx + hw, cy + hh], [cx - hw, cy + hh] ].all? { |x, y| point_in_polygon?(@outer, x, y) }
    end

    #-----------------------------------------------------------
    # オーバーラップ判定
    #-----------------------------------------------------------
    def overlap_round_round?(a, b, safe)
      dx = a[:cx] - b[:cx]
      dy = a[:cy] - b[:cy]
      dist2 = dx * dx + dy * dy
      r_sum = a[:r] + b[:r] + safe * 2
      dist2 < r_sum * r_sum
    end

    def overlap_rect_rect?(a, b, safe)
      ax1 = a[:cx] - a[:w] / 2 - safe
      ax2 = a[:cx] + a[:w] / 2 + safe
      ay1 = a[:cy] - a[:h] / 2 - safe
      ay2 = a[:cy] + a[:h] / 2 + safe

      bx1 = b[:cx] - b[:w] / 2 - safe
      bx2 = b[:cx] + b[:w] / 2 + safe
      by1 = b[:cy] - b[:h] / 2 - safe
      by2 = b[:cy] + b[:h] / 2 + safe

      ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1
    end

    def overlap_round_rect?(circ, rect, safe)
      dx = (circ[:cx] - rect[:cx]).abs - rect[:w] / 2 - safe
      dy = (circ[:cy] - rect[:cy]).abs - rect[:h] / 2 - safe
      dx = 0 if dx < 0
      dy = 0 if dy < 0
      (dx * dx + dy * dy) < (circ[:r] + safe) ** 2
    end

    #-----------------------------------------------------------
    # 汎用ユーティリティ
    #-----------------------------------------------------------
    def normalize_path(path)
      pts = path.map { |p| p.map(&:to_f) }
      pts << pts.first unless pts.first == pts.last
      pts
    end

    # Even‑odd ルール
    def point_in_polygon?(poly, x, y)
      inside = false
      j = poly.length - 1
      poly.each_with_index do |(xi, yi), i|
        xj, yj = poly[j]
        if (yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi
          inside = !inside
        end
        j = i
      end
      inside
    end

    def samples_on_circle(cx, cy, r, sides = 16)
      (0...sides).map do |i|
        a = 2 * Math::PI * i / sides
        [cx + Math.cos(a) * r, cy + Math.sin(a) * r]
      end
    end
  end
end
