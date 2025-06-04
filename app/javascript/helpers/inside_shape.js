// inside_shape.js — Shape containment helpers with safety margin
// -------------------------------------------------------------
// Utility to test whether a circle / rectangle lies fully inside a THREE.Shape
// within a given safety margin (mm).
//
// * pointInShape(shape,x,y)     – even‑odd rule on spaced points
// * insideRound(shape,hole,m)   – hole = {cx,cy,r},  margin m (default 0)
// * insideRect (shape,hole,m)   – hole = {cx,cy,w,h}, margin m (default 0)
//
// Usage example:
//   import { buildShape } from "helpers/shape_builders";
//   import { insideRound, insideRect } from "helpers/inside_shape";
//
//   const shape = buildShape(ctx);
//   if (!insideRound(shape,hole,30)) { /* validation error */ }

import * as THREE from "three";

/* ------------------------------------------------------------------
 * 1. 基本 – Shape 内に点が含まれるか (odd‑even rule)
 * ----------------------------------------------------------------*/
export function pointInShape(shape, x, y) {
  // 十分細かく分割された頂点列を取得
  const pts = shape.getSpacedPoints(Math.max(shape.getPoints().length * 4, 128));
  let inside = false;
  for (let i = 0, j = pts.length - 1; i < pts.length; j = i++) {
    const xi = pts[i].x, yi = pts[i].y;
    const xj = pts[j].x, yj = pts[j].y;
    const intersect = (yi > y) !== (yj > y) &&
      (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

/* ------------------------------------------------------------------
 * 2. 穴が外周から margin mm 以上内側か？
 * ----------------------------------------------------------------*/
export function insideRound(shape, { cx, cy, r }, margin = 0) {
  const R = r + margin;
  const sides = 16; // 円周を 16 分割で近似
  for (let i = 0; i < sides; i++) {
    const a = (Math.PI * 2 * i) / sides;
    const x = cx + Math.cos(a) * R;
    const y = cy + Math.sin(a) * R;
    if (!pointInShape(shape, x, y)) return false;
  }
  return true;
}

export function insideRect(shape, { cx, cy, w, h }, margin = 0) {
  const halfW = w / 2 + margin;
  const halfH = h / 2 + margin;
  return (
    pointInShape(shape, cx - halfW, cy - halfH) &&
    pointInShape(shape, cx + halfW, cy - halfH) &&
    pointInShape(shape, cx + halfW, cy + halfH) &&
    pointInShape(shape, cx - halfW, cy + halfH)
  );
}
