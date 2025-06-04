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

/* =========================================================================
 * buildRectCorners(ctx)
 *  左下(0,0) → 時計回りで外周を作り、ctx.corners の
 *  tl / tr / br / bl (code,r,dx,dy) に応じて 4 隅の加工を行う
 * ========================================================================= */
export function buildRectCorners(ctx) {
  const { L, W1: W, corners: C } = ctx;
  const s = new THREE.Shape();

  /* --- 1   スタート (bl) ---------------------------------------------- */
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  s.moveTo(blX, 0);

  /* --- 2   左下角 (bl) ------------------------------------------------- */
  switch (C.bl.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(C.bl.r, C.bl.r, C.bl.r, -Math.PI / 2, Math.PI, true);
      break;
    case "INROUND":
      s.absarc(0, 0, C.bl.r, 0, Math.PI / 2, false);
      break;
    case "CHAMFER":
      s.lineTo(C.bl.dx, C.bl.dy);
      s.lineTo(0, C.bl.dy);
      break;
    case "BEVEL":
      s.lineTo(0, C.bl.dy);
      break;
  }

  /* --- 3   左辺 → 左上加工開始位置 ------------------------------------ */
  const tlY = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dy : C.tl.r;
  s.lineTo(0, W - tlY);

  /* --- 4   左上角 (tl) ------------------------------------------------- */
  switch (C.tl.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(C.tl.r, W - C.tl.r, C.tl.r, Math.PI, Math.PI / 2, true);
      break;
    case "INROUND":
      s.absarc(0, W, C.tl.r, -Math.PI / 2, 0, false);
      break;
    case "CHAMFER":
      s.lineTo(C.tl.dx, W - C.tl.dy);
      s.lineTo(C.tl.dx, W);
      break;
    case "BEVEL":
      s.lineTo(C.tl.dx, W);
      break;
  }

  /* --- 5   上辺 → 右上加工開始位置 ------------------------------------ */
  const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? C.tr.dx : C.tr.r;
  s.lineTo(L - trX, W);

  /* --- 6   右上角 (tr) ------------------------------------------------- */
  switch (C.tr.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(L - C.tr.r, W - C.tr.r, C.tr.r, Math.PI / 2, 0, true);
      break;
    case "INROUND":
      s.absarc(L, W, C.tr.r, Math.PI, -Math.PI / 2, false);
      break;
    case "CHAMFER":
      s.lineTo(L - C.tr.dx, W - C.tr.dy);
      s.lineTo(L, W - C.tr.dy);
      break;
    case "BEVEL":
      s.lineTo(L, W - C.tr.dy);
      break;
  }

  /* --- 7   右辺 → 右下加工開始位置 ------------------------------------ */
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  s.lineTo(L, brY);

  /* --- 8   右下角 (br) ------------------------------------------------- */
  switch (C.br.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(L - C.br.r, C.br.r, C.br.r, 0, -Math.PI / 2, true);
      break;
    case "INROUND":
      s.absarc(L, 0, C.br.r, Math.PI / 2, Math.PI, false);
      break;
    case "CHAMFER":
      s.lineTo(L - C.br.dx, C.br.dy);
      s.lineTo(L - C.br.dx, 0);
      break;
    case "BEVEL":
      s.lineTo(L - C.br.dx, 0);
      break;
  }

  /* --- 9   下辺 (始点へ戻る) ------------------------------------------- */
  s.lineTo(blX, 0);

  _pushHoles(s, ctx);
  return s;
}


/*======================================================================*
 | 2. NICHE  (矩形 + 上部アーチ)                                        |
 *======================================================================*/
function buildNiche(ctx) {
//  const L = ctx.L;
//  const W1 = ctx.W1;     // 矩形部分の高さ
//  const W2 = ctx.W2;     // 全高
  const { L, W1, W2, corners: C } = ctx;
  const sag  = W2 - W1;               // 矢高
  const R    = (L ** 2) / (8 * sag) + (sag / 2); // 円弧半径
  const cx   = L / 2;                 // 円心 X
  const cy   = W2 - R;                // 円心 Y
  const theta = 2 * Math.asin(L / (2 * R)); // 弧の角度

  const s = new THREE.Shape();

  /* --- 1   スタート (bl) ---------------------------------------------- */
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  s.moveTo(blX, 0);

  /* --- 2   左下角 (bl) ------------------------------------------------- */
  switch (C.bl.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(C.bl.r, C.bl.r, C.bl.r, -Math.PI / 2, Math.PI, true);
      break;
    case "INROUND":
      s.absarc(0, 0, C.bl.r, 0, Math.PI / 2, false);
      break;
    case "CHAMFER":
      s.lineTo(C.bl.dx, C.bl.dy);
      s.lineTo(0, C.bl.dy);
      break;
    case "BEVEL":
      s.lineTo(0, C.bl.dy);
      break;
  }

  /* --- 3   左辺 → 左上加工開始位置 ------------------------------------ */
  s.lineTo(0, W1);

  /* --- 4   左上 → 右上 ------------------------------------ */
  s.absarc(cx, cy, R, Math.PI / 2 + (theta / 2), Math.PI / 2 - (theta / 2), true);

  /* --- 5   右辺 → 右下加工開始位置 ------------------------------------ */
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  s.lineTo(L, brY);

  /* --- 6   右下角 (br) ------------------------------------------------- */
  switch (C.br.code) {
    case "ROUND_R":
    case "NONE":
      s.absarc(L - C.br.r, C.br.r, C.br.r, 0, -Math.PI / 2, true);
      break;
    case "INROUND":
      s.absarc(L, 0, C.br.r, Math.PI / 2, Math.PI, false);
      break;
    case "CHAMFER":
      s.lineTo(L - C.br.dx, C.br.dy);
      s.lineTo(L - C.br.dx, 0);
      break;
    case "BEVEL":
      s.lineTo(L - C.br.dx, 0);
      break;
  }

  /* --- 7   下辺 (始点へ戻る) ------------------------------------------- */
  s.lineTo(blX, 0);

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
  s.lineTo(L / 2, W);
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
