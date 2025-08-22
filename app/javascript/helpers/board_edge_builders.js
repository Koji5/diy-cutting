import * as THREE from "three";

export function buildEdgeGeometries(cornerCtx, pos, L, W, T) {
  const DX = Number(cornerCtx?.dx);
  const DY = Number(cornerCtx?.dy);
  let CX = 0, CY = 0, signX = 1, signY = 1, pix = 0, piy = 0;
  switch (pos) {
    case "tl": CX = 0;  CY = W;  signX = +1; signY = -1; pix = Math.PI / 2; piy = Math.PI; break;
    case "tr": CX = L;  CY = W;  signX = -1; signY = -1; pix = Math.PI / 2; piy = 0; break;
    case "bl": CX = 0;  CY = 0;  signX = +1; signY = +1; pix = -Math.PI / 2; piy = Math.PI; break;
    case "br": CX = L;  CY = 0;  signX = -1; signY = +1; pix = -Math.PI / 2; piy = 0; break;
    default:
  }
  const h = DX > DY ? DY : DX;
  const l = DX > DY ? DX : DY;
  const r = ((l * 2) ** 2) / (8 * h) + h / 2;
  const theta = Math.asin(l / r);
  const a = notchWidthFromCode(cornerCtx.edge, T);
  const edgePath = new THREE.CurvePath();
  const cutters = [];
  const p1 = new THREE.Vector3(CX + DX * signX, CY, 0);
  const s = new THREE.Shape();
  s.moveTo(CX, CY);
  switch(cornerCtx.proc) {
    case "BEVEL":
      {
        const r   = Math.hypot(DX, DY);         // 斜辺
        s.lineTo(CX + DX * signX, CY)
        .lineTo(CX + (DX + a * DY / r) * signX, CY + (a * DX / r) * signY)
        .lineTo(CX + (a * DY / r) * signX, CY + (DY + a * DX / r) * signY)
        .lineTo(CX, CY + DY * signY);
        const p2 = new THREE.Vector3(CX, CY + DY * signY, 0);
        if (pos === "tl" || pos === "br"){
          edgePath.add( new THREE.LineCurve3( p1, p2 ));
        } else {
          edgePath.add( new THREE.LineCurve3( p2, p1));
        }
      }
      break;
    case "CHAMFER":
      {
        s.lineTo(CX + (DX + a) * signX, CY)
        .lineTo(CX + (DX + a) * signX, CY + DY * signY)
        .lineTo(CX + DX * signX, CY + DY * signY)
        .lineTo(CX + DX * signX, CY + (DY + a) * signY)
        .lineTo(CX, CY + (DY + a) * signY);
        const p2 = new THREE.Vector3(CX + DX * signX, CY + DY * signY, 0);
        const p3 = new THREE.Vector3(CX, CY + DY * signY, 0);
        if (pos === "tl" || pos === "br"){
          edgePath.add( new THREE.LineCurve3( p1, p2 ));
          edgePath.add( new THREE.LineCurve3( p2, p3 ));
        } else {
          edgePath.add( new THREE.LineCurve3( p3, p2 ));
          edgePath.add( new THREE.LineCurve3( p2, p1 ));
        }
      }
      break;
    case "ROUND_R":
      {
        const sx = DX > DY ? CX + signX * DX : CX + signX * r;
        const sy = DX > DY ? CY + signY * r : CY + signY * DY;
        const center = new THREE.Vector3(sx, sy, 0);
        let arc3;

        if (DX > DY) {
          s.lineTo(CX + DX * signX, CY)
          .lineTo(CX + DX * signX, CY + a * signY)//.lineTo(CX + DX * signX, CY)
          .absarc(sx, sy, r - a, pix, pix - signX * signY * theta, (signX * signY === 1))
          .lineTo(CX, CY + DY * signY);
          if (pos === "tl" || pos === "br"){
            arc3 = new ArcCurve3( center, r, pix, pix - signX * signY * theta, (signX * signY === 1));
          } else {
            arc3 = new ArcCurve3( center, r, pix - signX * signY * theta, pix, (signX * signY === -1));
          }
        } else {
          s.lineTo(CX, CY + DY * signY)
          .absarc(sx, sy, r - a, piy , piy + signX * signY * theta, (signX * signY === -1))
          .lineTo(CX + DX * signX, CY);
          if (pos === "tl" || pos === "br"){
            arc3 = new ArcCurve3( center, r, piy + signX * signY * theta, piy, (signX * signY === 1));
          } else {
            arc3 = new ArcCurve3( center, r, piy, piy + signX * signY * theta, (signX * signY === -1));
          }
        }
        edgePath.add(arc3);
      }
      break;
    case "INROUND":
      {
        const sx = DX > DY ? CX : CX + signX * (DX - r);
        const sy = DX > DY ? CY + signY * (DY - r) : CY;
        const center = new THREE.Vector3(sx, sy, 0);
        let arc3;
        if (DX > DY) {
          s.lineTo(CX + (DX + a) * signX, CY)
          .absarc(sx, sy, r + a, -pix - signX * signY * theta, -pix, (signX * signY === -1));
          if (pos === "tl" || pos === "br"){
            arc3 = new ArcCurve3( center, r, -pix - signX * signY * theta, -pix, (signX * signY === -1));
          } else {
            arc3 = new ArcCurve3( center, r, piy - signX * Math.PI, piy - signX * (Math.PI - signY * theta), (signX * signY === -1));
          }
        } else {
          s.lineTo(CX + (DX + a) * signX, CY)
          .absarc(sx, sy, r + a, piy - signX * Math.PI, piy - signX * (Math.PI - signY * theta) , (signX * signY === -1));
          if (pos === "tl" || pos === "br"){
            arc3 = new ArcCurve3( center, r, -pix, -pix - signX * signY * theta, (signX * signY === 1));
          } else {
            arc3 = new ArcCurve3( center, r, piy - signX * (Math.PI - signY * theta), piy - signX * Math.PI, (signX * signY === 1));
          }
        }
        edgePath.add(arc3);
      }
      break;
    default:
  }
  s.closePath();
  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)
  cutters.push(geo);

  return cutters
}

/** 帯の幅（mm）：エッジ加工コードから決める（例） */
function notchWidthFromCode(code, T){
  switch (code) {
    case "CHM10MM": return Math.min(10, Math.max(0, T*0.5 - 0.001));
    case "CHM5MM" : return Math.min( 5, Math.max(0, T*0.5 - 0.001));
    case "R5ROUND": return 5;
    case "R10ROUND":return 10;
    case "BULLNOSE":return T * 0.5; // ざっくり（必要なら調整）
    default:        return 5;       // デフォルト
  }
}





















function buildNotchGeometries(edgePath, code, T, rightSide=false, curveSegments=8) {
  if (!code || code === "NONE") return null;
  if (!edgePath?.curves?.length) return null;
  const a = notchWidthFromCode(code, T);
  const geos = [];
  for (const c of edgePath.curves) {
    if (c.isLineCurve3) {
      const p0 = c.v1 || c.getPoint(0); // LineCurve3(v1,v2) か getPoint で取得
      const p1 = c.v2 || c.getPoint(1);
      const shape = makeStripShape(p0, p1, a, rightSide);
      const geo = new THREE.ExtrudeGeometry(shape, {
        depth: T, bevelEnabled: false, curveSegments
      });
      geo.translate(0, 0, -T); // 上面Z=0（Z∈[-T,0]）に合わせる
      geos.push(geo.index ? geo.toNonIndexed() : geo);
      continue;
    }
    // ArcCurve3 相当（中心・半径・角度・回転向きを持つ）
    const hasArc = 'center' in c && ('radius' in c || ('xRadius' in c && 'yRadius' in c));
    if (hasArc) {
      const center    = c.center || new THREE.Vector3(0,0,0);
      const R         = c.radius ?? c.xRadius;  // 円弧想定
      const start     = c.startAngle ?? c.aStartAngle;
      const end       = c.endAngle   ?? c.aEndAngle;
      const clockwise = !!c.clockwise;

      // どちらが“内側”か：rightSide の向きに応じて半径を増減
      const Rin = rightSide ? R + a : R - a;
      const Rout = R;

      // もし Rin <= 0 になりそうならスキップ
      if (!Number.isFinite(Rin) || Rin <= 0) return null;

      const shape = makeAnnularSectorShape(center, Rout, Rin, start, end, clockwise);
      const geo = new THREE.ExtrudeGeometry(shape, {
        depth: T, bevelEnabled: false//, curveSegments
      });
      geo.translate(0, 0, -T);
      geos.push(geo.index ? geo.toNonIndexed() : geo);
      continue;
    }
  }
  return geos;
}



/** 円弧エッジの扇形リングの Shape（外半径 Rout、内半径 Rin） */
function makeAnnularSectorShape(center, Rout, Rin, a0, a1, clockwise){
  const m = 0.01;
  const cx = center.x, cy = center.y;
  const s = new THREE.Shape();
  // 外周スタート
  //s.moveTo(cx + (Rout + m)*Math.cos(a0), cy + (Rout + m)*Math.sin(a0));
  //s.absarc(cx, cy, Rout + m, a0, a1, clockwise);
  // 外→内へ放射状につなぐ
  s.lineTo(cx + Rin*Math.cos(a1), cy + Rin*Math.sin(a1));
  // 内周は逆回し
  s.absarc(cx, cy, Rin, a1, a0, !clockwise);
  //s.closePath();
  return s;
}





























export function createEdgeGeometry(code, T, edgePath, isReversed, type) {
  if (!code || code === "NONE") return null;
  if (!edgePath?.curves?.length) return null;
  if (edgePath.getLength() === 0) return null;

  let profile = type === "notch" ? notchProfile(code, T) : fillerProfile(code, T);
  if (isReversed) {
    const points = profile.getPoints().map(p => new THREE.Vector2(p.x, -p.y));
    profile = new THREE.Shape(points);
  }
//  function stepsForCurve(c) {
//    if (c.isLineCurve3)          return 1;                 // 直線は 1
//    const len  = c.getLength();                            // mm
//    const unit = c.isCubicBezierCurve3 ? 2 : 3;            // ベジエ 2 mm, それ以外 3 mm
//    return Math.max(1, Math.ceil(len / unit));
//  }
// 呼び出し側（ノッチは粗め / フィラーは細かめ）
const notchOpts  = { s: 0.12, maxDeg: 5, maxChord: 3 };  // ← 6.3°より細かくしたいなら maxDeg を 5→3 に
const fillerOpts = { s: 0.06, maxDeg: 3, maxChord: 2.5 };
const stepsSum = edgePath.curves.reduce(
  (sum, c) => sum + stepsForCurve(c, type==='notch' ? notchOpts : fillerOpts), 0
);
const steps = THREE.MathUtils.clamp(stepsSum|0, 6, 200); // 最終クランプ
//  const steps = edgePath.curves.reduce(
//    (sum, c) => sum + stepsForCurve(c), 0
//  );
//  const clampedSteps =  Math.max(16, Math.min(200, steps));
  let edgeGeo = null;
  try {
    edgeGeo = new THREE.ExtrudeGeometry(profile, {
      extrudePath  : edgePath,
      steps        : steps,
      bevelEnabled : false
    });
  } catch (e) {
    console.warn("ExtrudeGeometry 生成中にエラー:", key, e);
    edgeGeo?.dispose?.();
    return null; 
  }
  // 空ジオメトリは破棄して null
  const pos = edgeGeo.getAttribute('position');
  if (!pos || pos.count === 0) {
    edgeGeo.dispose();
    return null;
  }
  return edgeGeo;
}

function notchProfile(code, T) {
  // マージン
  const m = -0.01;
  const s = new THREE.Shape();
  s.moveTo(0, m);
  switch (code) {
    case "CHAMF_BTH":  // 上下糸面
      s.lineTo(T, m).lineTo(T, 1).lineTo(0, 1);
      break;
    case "BULLNOSE":  // ボーズ面
      s.lineTo(T, m).lineTo(T, T / 2).lineTo(0, T / 2);
      break;
    case "CHM5MM":  // 上下5mm面
    case "R5ROUND": // 上下5R面
      s.lineTo(T, m).lineTo(T, 5).lineTo(0, 5);
      break;
    case "CHM10MM": // 上下10mm面
    case "R10ROUND":  // 上下10R面
      s.lineTo(T, m).lineTo(T, 10).lineTo(0, 10);
      break;
    case "COVE": { // ギンナン面
      s.lineTo(9, m).lineTo(9, 9).lineTo(0, 9);
      break;
    }
    case "OGEE": { // 船底面
      s.lineTo(T - 5, m).lineTo(T - 5, T).lineTo(0, T);
      break;
    }
  }
  s.closePath();
  return s;
}

function fillerProfile(code, T) {
  // マージン
  const m = 0.01;
  const s = new THREE.Shape();
  //s.moveTo(0, 0);
  switch (code) {
//    case "CHAMF_BTH":  // 上下糸面
//      s.lineTo(T, 0).lineTo(T - 1, 1).lineTo(1, 1);
//      break;
    case "BULLNOSE":  // ボーズ面
//      s.lineTo(T, 0).lineTo(T, T / 2).lineTo(0, T / 2);
//      break;
    case "CHM5MM":  // 上下5mm面
//      s.lineTo(T, 0).lineTo(T - 5, 5).lineTo(5, 5);
//      break;
    case "R5ROUND": // 上下5R面
//      s.lineTo(T, 0).lineTo(T, 5).lineTo(0, 5);
//      break;
    case "CHM10MM": // 上下10mm面
      s.moveTo(10, 0);
      s.lineTo(T - 10, 0).lineTo(T, 10).lineTo(T, 10 + m).lineTo(0, 10 + m).lineTo(0, 10);
      break;
//    case "R10ROUND":  // 上下10R面
//      s.lineTo(T, 0).lineTo(T, 10).lineTo(0, 10);
//      break;
//    case "COVE": { // ギンナン面
//      s.lineTo(9, 0).lineTo(9, 9).lineTo(0, 9);
//      break;
//    }
//    case "OGEE": { // 船底面
//      s.lineTo(T - 5, 0).lineTo(T - 5, T).lineTo(0, T);
//      break;
//    }
  }
  s.closePath();
  return s;
}

function stepsForArcBySagitta(R, theta, s=0.15){
  if (!Number.isFinite(R) || R <= 0) return 2;
  const x = 1 - s / R;                     // cos(dθ/2) ≈ 1 - s/R
  const clamped = Math.max(-1, Math.min(1, x));
  const dSag = 2 * Math.acos(clamped);     // [rad]
  return (Number.isFinite(dSag) && dSag > 0) ? Math.ceil(theta / dSag) : 2;
}

function stepsForArc(R, theta, { s=0.15, maxDeg=6, maxChord=4 } = {}){
  const dSag   = 2 * Math.acos(Math.max(-1, Math.min(1, 1 - s/Math.max(R,1e-6))));
  const dDeg   = THREE.MathUtils.degToRad(maxDeg);
  const dChord = (maxChord>0 && R>maxChord/2)
    ? 2 * Math.asin(Math.min(1, maxChord/(2*R)))
    : Infinity;
  const dθ = Math.min(
    (Number.isFinite(dSag)   && dSag>0   ? dSag   : Infinity),
    (Number.isFinite(dDeg)   && dDeg>0   ? dDeg   : Infinity),
    (Number.isFinite(dChord) && dChord>0 ? dChord : Infinity)
  );
  return Math.max(2, Math.ceil(theta / dθ));
}

function stepsForCurve(c, opts){
  if (c.isLineCurve3) return 1;
  const hasAngles =
    ('startAngle' in c || 'aStartAngle' in c) &&
    ('endAngle'   in c || 'aEndAngle'   in c);
  if (hasAngles && ('radius' in c || 'xRadius' in c)) {
    const R = c.radius ?? c.xRadius ?? c.yRadius ?? 50;
    const θ = Math.abs((c.endAngle ?? c.aEndAngle) - (c.startAngle ?? c.aStartAngle));
    return stepsForArc(R, θ, opts);
  }
  // ベジエ等は長さ基準
  const len = c.getLength?.() ?? 10;
  const chordMax = opts?.maxChord ?? 4;
  return Math.max(2, Math.ceil(len / chordMax));
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
