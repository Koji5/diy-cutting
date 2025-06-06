# app/lib/point_in_polygon.rb
# -----------------------------------------------------------------------------
# シンプルな even‑odd 法則による Point‑in‑Polygon 判定ユーティリティ。
# poly : [[x1,y1], [x2,y2], ...]  (最後は閉じずとも OK、必ず CW or CCW)
# x,y  : 判定したい点。true = 内側, false = 外側
# -----------------------------------------------------------------------------
module PointInPolygon
  module_function

  def inside?(poly, x, y)
    inside = false
    j = poly.length - 1

    poly.each_with_index do |(xi, yi), i|
      xj, yj = poly[j]

      intersect = ((yi > y) != (yj > y)) &&
                  (x < (xj - xi) * (y - yi) / (yj - yi + 0.0) + xi)

      inside = !inside if intersect
      j = i
    end

    inside
  end
end
