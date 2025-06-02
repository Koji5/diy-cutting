// shape_builders.js — 3‑pattern version (geoCtx)
// --------------------------------------------------------------
// 依存: three.js を import map / Vite 等で pin 済み
import * as THREE from "three";

/*
 * geoCtx 必須フィールド
 *   shapeCode : "TRI_EQ" | "NICHE" | その他
 *   L, W1, (W2)  : mm  単位は左下原点・時計回り系
 *   corners      : tl / tr / bl / br それぞれ { code, r, dx, dy }
 *   holes_round  : [{ cx, cy, r,  … }]
 *   holes_square : [{ cx, cy, w,h … }]
 *   T            : 厚み (3D で使用)
 */

export function buildShape(ctx) {
  switch (ctx.shapeCode) {
    case "TRI_EQ":  return buildEquilateral(ctx);
    case "NICHE":   return buildNiche(ctx);
    default:         return buildRectCorners(ctx);   // "その他" は矩形 + 任意コーナー
  }
}

/*======================================================================*
 |  1. デフォルト: 基本矩形 + 任意コーナー加工                          |
 *======================================================================*/
function buildRectCorners(ctx) {
  const L = ctx.L;
  const W = ctx.W1;
  const s = new THREE.Shape();

  // 左下→左上→右上→右下→閉じる (CW)
  s.moveTo(0, 0);
  _corner(s, "bl", ctx.corners?.bl, L, W);
  s.lineTo(0, W);
  _corner(s, "tl", ctx.corners?.tl, L, W);
  s.lineTo(L, W);
  _corner(s, "tr", ctx.corners?.tr, L, W);
  s.lineTo(L, 0);
  _corner(s, "br", ctx.corners?.br, L, W);
  s.closePath();

  _pushHoles(s, ctx);
  return s;
}

/*======================================================================*
 | 2. NICHE  (矩形 + 上部アーチ)                                        |
 *======================================================================*/
function buildNiche(ctx) {
  const L = ctx.L;
  const W1 = ctx.W1;     // 全高
  const W2 = ctx.W2 ?? W1; // 下段高さ (省略時 = 全高 → 通常矩形と同じ)

  if (W2 >= W1) return buildRectCorners(ctx); // ニッチ無し

  const sag  = W1 - W2;               // 矢高
  const R    = (L ** 2 + 4 * sag ** 2) / (8 * sag); // 円弧半径
  const cx   = L / 2;                 // 円心 X
  const cy   = W2 - (R - sag);        // 円心 Y (左下原点)
  const theta = Math.acos((cx - 0) / R); // 左端角度

  const s = new THREE.Shape();
  s.moveTo(0, 0);
  s.lineTo(0, W2);
  s.absarc(cx, cy, R, Math.PI - theta, theta, true); // CW
  s.lineTo(L, 0);
  s.closePath();

  _pushHoles(s, ctx);
  return s;
}

/*======================================================================*
 | 3. 正三角形 (TRI_EQ)                                                 |
 *======================================================================*/
function buildEquilateral(ctx) {
  const W = ctx.W1;   // 高さ
  const L = ctx.L;    // 底辺
  const s = new THREE.Shape();
  s.moveTo(0, 0);
  s.lineTo(0, W);
  s.lineTo(L, 0);
  s.closePath();

  _pushHoles(s, ctx);
  return s;
}

/*======================================================================*
 | 4. 共通ヘルパ                                                        |
 *======================================================================*/
function _pushHoles(shape, ctx) {
  ctx.holes_round?.forEach(h => shape.holes.push(roundPath(h)));
  ctx.holes_square?.forEach(h => shape.holes.push(rectPath(h)));
}

function _corner(shape, pos, cfg = {}, L, W) {
  if (!cfg || cfg.code === "NONE") return;
  const { code, r = 0, dx = 0, dy = 0 } = cfg;
  if (!r && !dx && !dy) return;        // 全パラメータ 0 → 直角

  const P = { tl: [0, W], tr: [L, W], br: [L, 0], bl: [0, 0] }[pos];

  switch (code) {
    case "ROUND_R": {                // 凸R
      const R = r; if (!R) break;
      const cx = P[0] + (pos.endsWith("r") ? -R : R);
      const cy = P[1] + (pos.startsWith("t") ? -R : R);
      const a0 = { tl: Math.PI/2, tr: 0, br: -Math.PI/2, bl: Math.PI }[pos];
      shape.absarc(cx, cy, R, a0, a0 + Math.PI/2, true);
      break;
    }
    case "INROUND": {               // 凹R
      const R = r; if (!R) break;
      const cx = P[0] + (pos.endsWith("r") ? R : -R);
      const cy = P[1] + (pos.startsWith("t") ? R : -R);
      const a0 = { tl: Math.PI, tr: Math.PI/2, br: 0, bl: -Math.PI/2 }[pos];
      shape.absarc(cx, cy, R, a0, a0 - Math.PI/2, false);
      break;
    }
    case "CHAMFER": {
      if (!dx || !dy) break;
      const vx = pos.endsWith("r") ? -dx : dx;
      const vy = pos.startsWith("t") ? -dy : dy;
      shape.lineTo(P[0] + vx, P[1]);
      shape.lineTo(P[0] + vx, P[1] + vy);
      shape.lineTo(P[0],      P[1] + vy);
      break;
    }
    case "BEVEL": {
      const off = r || Math.min(dx, dy); if (!off) break;
      const vx = pos.endsWith("r") ? -off : off;
      const vy = pos.startsWith("t") ? -off : off;
      shape.lineTo(P[0] + vx, P[1] + vy);
      break;
    }
  }
}

function roundPath({ cx, cy, r }) {
  const p = new THREE.Path();
  p.absarc(cx, cy, r, 0, Math.PI * 2, false); // CCW → 穴
  return p;
}

function rectPath({ cx, cy, w, h }) {
  const p = new THREE.Path();
  p.moveTo(cx - w/2, cy - h/2);
  p.lineTo(cx + w/2, cy - h/2);
  p.lineTo(cx + w/2, cy + h/2);
  p.lineTo(cx - w/2, cy + h/2);
  p.closePath();
  return p;
}

// デフォルトエクスポートはしない (tree‑shaking 用)
export { buildRectCorners, buildNiche, buildEquilateral };