// inside_shape.js — Shape containment & overlap helpers
// --------------------------------------------------------------
// 依存: three.js (for THREE.Shape) は import-map / Vite 等で pin 済み
import * as THREE from "three";
import { GEOM_CFG } from "config/geometry";

/*================================================================
 | 1. Point‑in‑Shape (even‑odd rule)                              |
 *================================================================*/
export function pointInShape (shape, x, y) {
  // 十分細かく分割（円弧・ベジエを離散化）
  const pts = shape.getSpacedPoints(Math.max(shape.getPoints().length * 4, 128));
  let inside = false;
  for (let i = 0, j = pts.length - 1; i < pts.length; j = i++) {
    const xi = pts[i].x, yi = pts[i].y;
    const xj = pts[j].x, yj = pts[j].y;
    const intersect = ((yi > y) !== (yj > y)) &&
                      (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

/*================================================================
 | 2. “穴が完全に内側か？” 判定（安全マージン margin mm）        |
 *================================================================*/
export function insideRound (shape, { cx, cy, r }, margin = 0) {
  const R = r + margin;
  const sides = 16;
  for (let i = 0; i < sides; i++) {
    const a = (Math.PI * 2 * i) / sides;
    const x = cx + Math.cos(a) * R;
    const y = cy + Math.sin(a) * R;
    if (!pointInShape(shape, x, y)) return false;
  }
  return true;
}

export function insideRect (shape, { cx, cy, w, h }, margin = 0) {
  const hw = w / 2 + margin;
  const hh = h / 2 + margin;
  return (
    pointInShape(shape, cx - hw, cy - hh) &&
    pointInShape(shape, cx + hw, cy - hh) &&
    pointInShape(shape, cx + hw, cy + hh) &&
    pointInShape(shape, cx - hw, cy + hh)
  );
}

/*================================================================
 | 3. 穴どうしオーバーラップ判定                                 |
 *================================================================*/
const sq = x => x * x;

export function overlapRoundRound (a, b, safe = GEOM_CFG.safe_overlap_mm) {
  const dx = a.cx - b.cx, dy = a.cy - b.cy;
  const dist2 = dx * dx + dy * dy;
  const R = a.r + b.r + safe * 2;
  return dist2 < sq(R);
}

export function overlapRectRect (a, b, safe = GEOM_CFG.safe_overlap_mm) {
  const ax1 = a.cx - a.w / 2 - safe, ax2 = a.cx + a.w / 2 + safe;
  const ay1 = a.cy - a.h / 2 - safe, ay2 = a.cy + a.h / 2 + safe;
  const bx1 = b.cx - b.w / 2 - safe, bx2 = b.cx + b.w / 2 + safe;
  const by1 = b.cy - b.h / 2 - safe, by2 = b.cy + b.h / 2 + safe;
  return ax1 < bx2 && ax2 > bx1 && ay1 < by2 && ay2 > by1;
}

export function overlapRoundRect (circ, rect, safe = GEOM_CFG.safe_overlap_mm) {
  const dx = Math.max(Math.abs(circ.cx - rect.cx) - rect.w / 2 - safe, 0);
  const dy = Math.max(Math.abs(circ.cy - rect.cy) - rect.h / 2 - safe, 0);
  return (dx * dx + dy * dy) < sq(circ.r + safe);
}
