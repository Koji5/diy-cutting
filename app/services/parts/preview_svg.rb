# app/services/parts/preview_svg.rb
module Parts
  class PreviewSvg
    class << self
      # outer: [[x,y], …]   holes: [{ shape:, cx:, cy:, r:|w:/h: }, …]
      def call(outer, holes)
        # ① 外周のバウンディングボックスを取得
        xs, ys = outer.transpose
        width  = xs.max - xs.min
        height = ys.max - ys.min

        # ② SVG ヘッダ
        svg = +"<svg viewBox='0 0 #{width} #{height}' "\
                "xmlns='http://www.w3.org/2000/svg'>"
        svg << "  <g transform='scale(1,-1) translate(0,-#{height})'>"

        # ③ ポリライン（赤）
        pts = outer.map { |x, y| "#{x},#{y}" }.join(" ")
        svg << "<polygon points='#{pts}' fill='red' stroke='black'/>"

        # ④ 穴（黄色）
        holes.each do |h|
          case h[:shape]
          when :circle
            svg << "<circle cx='#{h[:cx]}' cy='#{h[:cy]}' "\
                   "r='#{h[:r]}' fill='none' stroke='yellow'/>"
          when :rect
            x = h[:cx] - h[:w] / 2.0
            y = h[:cy] - h[:h] / 2.0
            svg << "<rect x='#{x}' y='#{y}' "\
                   "width='#{h[:w]}' height='#{h[:h]}' "\
                   "fill='none' stroke='yellow'/>"
          end
        end

        svg << "</g></svg>"
      end
    end
  end
end
