import * as THREE from "three";

export function buildShape(ctx) {
  switch (ctx.shapeCode) {
    case "TRI_EQ":  return buildEquilateral(ctx);
    case "NICHE":   return buildNiche(ctx);
    default:         return buildRect(ctx);   // "その他" は矩形 + 任意コーナー
  }
}

export function buildEgePath(ctx, key) {
  switch (ctx.shapeCode) {
    case "TRI_EQ":  return buildEquilateralEgePath(ctx, key);
    case "NICHE":   return buildNicheEgePath(ctx, key);
    default:         return buildRectEgePath(ctx, key);
  }
}

function buildRectEgePath(ctx, key){
  const path = new THREE.CurvePath();
  switch(key){
    case "tl":
      build3DRectTl(path, ctx);
      break;
    case "t":
      build3DRectT(path, ctx);
      break;
    case "tr":
      build3DRectTr(path, ctx);
      break;
    case "l":
      build3DRectL(path, ctx);
      break;
    case "r":
      build3DRectR(path, ctx);
      break;
    case "bl":
      build3DRectBl(path, ctx);
      break;
    case "b":
      build3DRectB(path, ctx);
      break;
    case "br":
      build3DRectBr(path, ctx);
      break;
  }
  return path;
}
function buildNicheEgePath(ctx, key){
  const path = new THREE.CurvePath();
  switch(key){
    case "t":
      build3DNicheT(path, ctx);
      break;
    case "l":
      build3DRectL(path, ctx);
      break;
    case "r":
      build3DRectR(path, ctx);
      break;
    case "bl":
      build3DRectBl(path, ctx);
      break;
    case "b":
      build3DRectB(path, ctx);
      break;
    case "br":
      build3DRectBr(path, ctx);
      break;
  }
  return path;
}
function buildEquilateralEgePath(ctx, key){
  const path = new THREE.CurvePath();
  switch(key){
    case "tl":
      build3DEquilateralTl(path, ctx);
      break;
    case "tr":
      build3DEquilateralTr(path, ctx);
      break;
    case "b":
      build3DRectB(path, ctx);
      break;
  }
  return path;
}
/* =========================================================================
 * buildRect(ctx)
 *  左下(0,0) → 時計回りで外周を作り、ctx.corners の
 *  tl / tr / br / bl (code,r,dx,dy) に応じて 4 隅の加工を行う
 * ========================================================================= */
function buildRect(ctx) {
  const s = new THREE.Shape();
  const startBl = startRectBl(ctx);
  s.moveTo(startBl.x, startBl.y);
  buildRectBl(s, ctx);
  buildRectL(s, ctx);
  buildRectTl(s, ctx);
  buildRectT(s, ctx);
  buildRectTr(s, ctx);
  buildRectR(s, ctx);
  buildRectBr(s, ctx);
  buildRectB(s, ctx);
  _pushHoles(s, ctx);
  return s;
}

/*======================================================================*
 | 2. NICHE  (矩形 + 上部アーチ)                                        |
 *======================================================================*/
function buildNiche(ctx) {
  const s = new THREE.Shape();
  const startBl = startRectBl(ctx);
  s.moveTo(startBl.x, startBl.y);
  buildRectBl(s, ctx);
  buildRectL(s, ctx);
  buildNicheT(s, ctx);
  buildRectR(s, ctx);
  buildRectBr(s, ctx);
  buildRectB(s, ctx);
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
  const startBl = startRectBl(ctx);
  s.moveTo(startBl.x, startBl.y);
  buildEquilateralTl(s, ctx);
  buildEquilateralTr(s, ctx);
  buildRectB(s, ctx);
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

// -----Bl-----
function startRectBl(ctx) {
  const { corners: C } = ctx;
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  return new THREE.Vector2(blX, 0);
}
function buildRectBl(s, ctx) {
  const { corners: C } = ctx;
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
}
function build3DRectBl(path, ctx) {
  const { corners: C } = ctx;
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  const startBl = new THREE.Vector3(blX, 0, 0);
  switch (C.bl.code) {
    case "ROUND_R":
    case "NONE": {
      const center = new THREE.Vector3(C.bl.r, C.bl.r, 0);
      path.add(arc90Bezier(center, C.bl.r, -Math.PI / 2, false));
      break;
    }
    case "INROUND": {
      const center = new THREE.Vector3(0, 0, 0);
      path.add(arc90Bezier(center, C.bl.r, 0, true));
      break;
    }
    case "CHAMFER": {
      const p1 = new THREE.Vector3(C.bl.dx, C.bl.dy, 0);
      const p2 = new THREE.Vector3(0, C.bl.dy, 0);
      path.add( new THREE.LineCurve3( startBl, p1 ));
      path.add( new THREE.LineCurve3( p1, p2 ));
      break;
    }
    case "BEVEL": {
      const p1 = new THREE.Vector3(0, C.bl.dy, 0);
      path.add( new THREE.LineCurve3( startBl, p1 ));
      break;
    }
  }
}
// -----L-----
function buildRectL(s, ctx) {
  const { W1: W, corners: C } = ctx;
  const tlY = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dy : C.tl.r;
  s.lineTo(0, W - tlY);
}
function build3DRectL(path, ctx) {
  const { W1: W, corners: C } = ctx;
  const lY = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dy : C.bl.r;
  const tlY = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dy : C.tl.r;
  const startL = new THREE.Vector3(0, lY, 0);
  const endL = new THREE.Vector3(0, W - tlY, 0);
  path.add( new THREE.LineCurve3( startL, endL ));
}
// -----Tl-----
function buildRectTl(s, ctx) {
  const { W1: W, corners: C } = ctx;
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
}
function build3DRectTl(path, ctx) {
  const { W1: W, corners: C } = ctx;
  const tlY = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? W - C.tl.dy : W - C.tl.r;
  const startTl = new THREE.Vector3(0, tlY, 0);
  switch (C.tl.code) {
    case "ROUND_R":
    case "NONE": {
      const center = new THREE.Vector3(C.tl.r, W - C.tl.r, 0);
      path.add(arc90Bezier(center, C.tl.r, Math.PI, false));
      break;
    }
    case "INROUND": {
      const center = new THREE.Vector3(0, W, 0);
      path.add(arc90Bezier(center, C.bl.r, -Math.PI / 2, true));
      break;
    }
    case "CHAMFER": {
      const p1 = new THREE.Vector3(C.tl.dx, W - C.tl.dy, 0);
      const p2 = new THREE.Vector3(C.tl.dx, W, 0);
      path.add( new THREE.LineCurve3( startTl, p1 ));
      path.add( new THREE.LineCurve3( p1, p2 ));
      break;
    }
    case "BEVEL": {
      const p1 = new THREE.Vector3(C.tl.dx, W, 0);
      path.add( new THREE.LineCurve3( startTl, p1 ));
      break;
    }
  }
}
// -----T-----
function buildRectT(s, ctx) {
  const { L, W1: W, corners: C } = ctx;
  const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? C.tr.dx : C.tr.r;
  s.lineTo(L - trX, W);
}
function build3DRectT(path, ctx) {
  const { L, W1: W, corners: C } = ctx;
  const tX = C.tl.code === "CHAMFER" || C.tl.code === "BEVEL" ? C.tl.dx : C.tl.r;
  const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? C.tr.dx : C.tr.r;
  const startT = new THREE.Vector3(tX, W, 0);
  const endT = new THREE.Vector3(L - trX, W, 0);
  path.add( new THREE.LineCurve3( startT, endT ));
}
// -----Tr-----
function buildRectTr(s, ctx) {
  const { L, W1: W, corners: C } = ctx;
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
}
function build3DRectTr(path, ctx) {
  const { L, W1: W, corners: C } = ctx;
  const trX = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? L - C.tr.dx : L - C.tr.r;
  const startTr = new THREE.Vector3(trX, W, 0);
  switch (C.tr.code) {
    case "ROUND_R":
    case "NONE": {
      const center = new THREE.Vector3(L - C.tr.r, W - C.tr.r, 0);
      path.add(arc90Bezier(center, C.tr.r, Math.PI / 2, false));
      break;
    }
    case "INROUND": {
      const center = new THREE.Vector3(L, W, 0);
      path.add(arc90Bezier(center, C.tr.r, Math.PI, true));
      break;
    }
    case "CHAMFER": {
      const p1 = new THREE.Vector3(L - C.tr.dx, W - C.tr.dy, 0);
      const p2 = new THREE.Vector3(L, W - C.tr.dy, 0);
      path.add( new THREE.LineCurve3( startTr, p1 ));
      path.add( new THREE.LineCurve3( p1, p2 ));
      break;
    }
    case "BEVEL": {
      const p1 = new THREE.Vector3(L, W - C.tr.dy, 0);
      path.add( new THREE.LineCurve3( startTr, p1 ));
      break;
    }
  }
}
// -----R-----
function buildRectR(s, ctx) {
  const { L, corners: C } = ctx;
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  s.lineTo(L, brY);
}
function build3DRectR(path, ctx) {
  const { L, W1: W, corners: C } = ctx;
  const rY = C.tr.code === "CHAMFER" || C.tr.code === "BEVEL" ? W - C.tr.dy : W - C.tr.r;
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  const startR = new THREE.Vector3(L, rY, 0);
  const endR = new THREE.Vector3(L, brY, 0);
  path.add( new THREE.LineCurve3( startR, endR ));
}
// -----Br-----
function buildRectBr(s, ctx) {
  const { L, corners: C } = ctx;
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
}
function build3DRectBr(path, ctx) {
  const { L, corners: C } = ctx;
  const brY = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? C.br.dy : C.br.r;
  const startBr = new THREE.Vector3(L, brY, 0);
  switch (C.br.code) {
    case "ROUND_R":
    case "NONE": {
      const center = new THREE.Vector3(L - C.br.r, C.br.r, 0);
      path.add(arc90Bezier(center, C.br.r, 0, false));
      break;
    }
    case "INROUND": {
      const center = new THREE.Vector3(L, 0, 0);
      path.add(arc90Bezier(center, C.br.r, Math.PI / 2, true));
      break;
    }
    case "CHAMFER": {
      const p1 = new THREE.Vector3(L - C.br.dx, C.br.dy, 0);
      const p2 = new THREE.Vector3(L - C.br.dx, 0, 0);
      path.add( new THREE.LineCurve3( startBr, p1 ));
      path.add( new THREE.LineCurve3( p1, p2 ));
      break;
    }
    case "BEVEL": {
      const p1 = new THREE.Vector3(L - C.br.dx, 0, 0);
      path.add( new THREE.LineCurve3( startBr, p1 ));
      break;
    }
  }
}
// -----B-----
function buildRectB(s, ctx) {
  const { corners: C } = ctx;
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  s.lineTo(blX, 0);
}
function build3DRectB(path, ctx) {
  const { L, corners: C } = ctx;
  const bX = C.br.code === "CHAMFER" || C.br.code === "BEVEL" ? L - C.br.dx : L - C.br.r;
  const blX = C.bl.code === "CHAMFER" || C.bl.code === "BEVEL" ? C.bl.dx : C.bl.r;
  const startB = new THREE.Vector3(bX, 0, 0);
  const endB = new THREE.Vector3(blX, 0, 0);
  path.add( new THREE.LineCurve3( startB, endB ));
}
function buildNicheT(s, ctx) {
  const { L, W1, W2 } = ctx;
  const sag  = W2 - W1;               // 矢高
  const R    = (L ** 2) / (8 * sag) + (sag / 2); // 円弧半径
  const cx   = L / 2;                 // 円心 X
  const cy   = W2 - R;                // 円心 Y
  const theta = 2 * Math.asin(L / (2 * R)); // 弧の角度
  s.absarc(cx, cy, R, Math.PI / 2 + (theta / 2), Math.PI / 2 - (theta / 2), true);
}
function build3DNicheT(path, ctx) {
  const { L, W1, W2 } = ctx;
  const sag   = W2 - W1;                      // 矢高
  const R     = (L ** 2) / (8 * sag) + sag / 2;
  const cx    =  L / 2;
  const cy    =  W2 - R;
  const theta = 2 * Math.asin(L / (2 * R));   // 弧の中心角
  // 2) 始角 a0, 終角 a1  （XY で上向き 0°=+X 軸想定）
  const a0 = Math.PI / 2 + theta / 2;   // 左端
  const a1 = Math.PI / 2 - theta / 2;   // 右端
  const center = new THREE.Vector3(cx, cy, 0);
  const arc3 = new ArcCurve3( center, R, a0, a1, false );
  path.add(arc3);
}
function buildEquilateralTl(s, ctx) {
  const { L, W1: W } = ctx;
  s.lineTo(L / 2, W);
}
function build3DEquilateralTl(path, ctx) {
  const { L, W1: W } = ctx;
  const startTl = new THREE.Vector3(0, 0, 0);
  const endTl = new THREE.Vector3(L / 2, W, 0);
  path.add( new THREE.LineCurve3( startTl, endTl ));
}
function buildEquilateralTr(s, ctx) {
  const { L } = ctx;
  s.lineTo(L, 0);
}
function build3DEquilateralTr(path, ctx) {
  const { L, W1: W, corners: C } = ctx;
  const startTr = new THREE.Vector3(L / 2, W, 0);
  const endTr = new THREE.Vector3(L, 0, 0);
  path.add( new THREE.LineCurve3( startTr, endTr ));
}

function arc90Bezier(center, radius, startAngle, ccw) {
  const sign = ccw ? 1 : -1;                  // 方向
  const a0 = startAngle;
  const a1 = a0 + sign * Math.PI/2;
  const k  = (4/3) * radius * Math.tan(Math.PI/8);

  const u  = new THREE.Vector2(Math.cos(a0), Math.sin(a0));
  const v  = new THREE.Vector2(Math.cos(a1), Math.sin(a1));

  const up = new THREE.Vector2(-sign*u.y, sign*u.x); // +90°(ccw) or -90°(cw)
  const vp = new THREE.Vector2(+sign*v.y, -sign*v.x);

  const toV3 = (vec2) => new THREE.Vector3(vec2.x, vec2.y, 0);

  const p0 = toV3(u.clone().multiplyScalar(radius).add(center));
  const p3 = toV3(v.clone().multiplyScalar(radius).add(center));
  const p1 = toV3(p0.clone().add(up.multiplyScalar(k)));
  const p2 = toV3(p3.clone().add(vp.multiplyScalar(k)));

  return new THREE.CubicBezierCurve3(p0, p1, p2, p3);
}
class ArcCurve3 extends THREE.Curve {
  constructor( center, radius, startAngle, endAngle, clockwise = false ) {
    super();
    this.center = center.clone();
    this.radius = radius;
    this.startAngle = startAngle;
    this.endAngle   = endAngle;
    this.clockwise  = clockwise;
  }
  getPoint( t, target = new THREE.Vector3() ) {
    // t = 0 → startAngle, t = 1 → endAngle
    const angle = this.clockwise
      ? this.startAngle - t * ( this.startAngle - this.endAngle )
      : this.startAngle + t * ( this.endAngle - this.startAngle );

    target.set(
      this.center.x + this.radius * Math.cos( angle ),
      this.center.y + this.radius * Math.sin( angle ),
      0
    );
    return target;
  }
}
