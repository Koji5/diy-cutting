import * as THREE from "three";
import { unionMesh } from "helpers/bvh_csg_utils";

export function buildCornerEdgeGeometries(cornerCtx, pos, L, W, T) {
  const code = cornerCtx.edge;
  if (!code || code === "NONE") return null;
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
  const a = notchWidthFromCode(code, T);
  if (!a) return null;
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
  cutters.push(buildFillerGeometry(code, T, edgePath));
  cutters.push(buildCavityGeometry(code, T, edgePath));
  return cutters
}

/** 帯の幅（mm）：エッジ加工コードから決める（例） */
function notchWidthFromCode(code, T){
  switch (code) {
    case "CHAMF_BTH": return 1;
    case "BULLNOSE":return T / 2;
    case "CHM5MM" : return 5;
    case "R5ROUND": return 5;
    case "CHM10MM": return 10;
    case "R10ROUND": return 10;
    case "COVE": return 9;
    case "OGEE": return T - 10 / Math.sqrt(2);
    default: return null;
  }
}

function buildFillerGeometry(code, T, edgePath) {
  // マージン
  const m = 0.01;
  const s = new THREE.Shape();
  switch (code) {
    case "CHAMF_BTH":
      s.moveTo(1, 0);
      s.lineTo(T - 1, 0).lineTo(T, 1).lineTo(T, 1 + m).lineTo(0, 1 + m).lineTo(0, 1);
      break;
    case "BULLNOSE":  // ボーズ面
      s.moveTo(0, T / 2);
      s.absarc(T / 2, T / 2, T / 2, Math.PI, 0, false);
      s.lineTo(T, T / 2 + m).lineTo(0, T / 2 + m);
      break;
    case "CHM5MM":  // 上下5mm面
      s.moveTo(5, 0);
      s.lineTo(T - 5, 0).lineTo(T, 5).lineTo(T, 5 + m).lineTo(0, 5 + m).lineTo(0, 5);
      break;
    case "R5ROUND": // 上下5R面
      s.moveTo(5, 0);
      s.absarc(5,  5, 5, Math.PI, -Math.PI / 2, false);
      s.lineTo(T - 5, 0);
      s.absarc(T - 5,  5, 5, -Math.PI / 2, 0, false);
      s.lineTo(T, 5 + m);
      break;
    case "CHM10MM": // 上下10mm面
      s.moveTo(10, 0);
      s.lineTo(T - 10, 0).lineTo(T, 10).lineTo(T, 10 + m).lineTo(0, 10 + m).lineTo(0, 10);
      break;
    case "R10ROUND":  // 上下10R面
      s.moveTo(10, 0);
      s.absarc(10,  10, 10, Math.PI, -Math.PI / 2, false);
      s.lineTo(T - 10, 0);
      s.absarc(T - 10,  10, 10, -Math.PI / 2, 0, false);
      s.lineTo(T, 10 + m);
      break;
    case "COVE":  // ギンナン面
      s.moveTo(0, 9).lineTo(3, 9);
      s.absarc(9, 9, 6, Math.PI, -Math.PI / 2, false);
      s.lineTo(9, 0).lineTo(T, 0).lineTo(T, 9 + m).lineTo(0, 9 + m);
      break;
    case "OGEE": { // 船底面
      const l = T - 10 / Math.sqrt(2);
      s.moveTo(0, 5);
      s.absarc(5, 5, 5, Math.PI, -Math.PI / 4, false);
      s.lineTo(T, l).lineTo(T, l + m).lineTo(0, l + m);
      break;
    }
  }
  s.closePath();
  return extrudeAlongPath(s, edgePath);
}

function buildCavityGeometry(code, T, edgePath){
  // マージン
  const m = -0.01;
  const s = new THREE.Shape();
  s.moveTo(0, m);
  switch (code) {
    case "CHAMF_BTH":
      s.lineTo(T, m).lineTo(T, 1).lineTo(T - 1, 0).lineTo(1, 0).lineTo(0, 1);
      break;
    case "BULLNOSE":  // ボーズ面
      s.lineTo(T, m).lineTo(T, T / 2);
      s.absarc(T / 2, T / 2, T / 2, 0, Math.PI, true);
      break;
    case "CHM5MM":  // 上下5mm面
      s.lineTo(T, m).lineTo(T, 5).lineTo(T - 5, 0).lineTo(5, 0).lineTo(0, 5);
      break;
    case "R5ROUND": // 上下5R面
      s.lineTo(T, m).lineTo(T, 5);
      s.absarc(T - 5,  5, 5, 0, -Math.PI / 2, true);
      s.lineTo(5, 0);
      s.absarc(5,  5, 5, -Math.PI / 2, Math.PI, true);
      break;
    case "CHM10MM": // 上下10mm面
      s.lineTo(T, m).lineTo(T, 10).lineTo(T - 10, 0).lineTo(10, 0).lineTo(0, 10);
      break;
    case "R10ROUND":  // 上下10R面
      s.lineTo(T, m).lineTo(T, 10);
      s.absarc(T - 10,  10, 10, 0, -Math.PI / 2, true);
      s.lineTo(10, 0);
      s.absarc(10,  10, 10, -Math.PI / 2, Math.PI, true);
      break;
    case "COVE":  // ギンナン面
      s.lineTo(9, m).lineTo(9, 3);
      s.absarc(9, 9, 6, -Math.PI / 2, Math.PI, true);
      s.lineTo(0, 9);
      break;
    case "OGEE": { // 船底面
      const l = T - 10 / Math.sqrt(2);
      s.lineTo(0, 5);
      s.absarc(5, 5, 5, Math.PI, -Math.PI / 4, false);
      s.lineTo(T, l).lineTo(T, m);
      break;
    }
  }
  s.closePath();
  return extrudeAlongPath(s, edgePath);
}

function extrudeAlongPath(shape, edgePath) {
  const fillerOpts = { s: 0.1, maxDeg: 3, maxChord: 4 };

  let resultMesh = null;
  for (const c of edgePath.curves) {
    const steps = THREE.MathUtils.clamp(stepsForCurve(c, fillerOpts), 6, 400);
    let geo = null;
    try {
      geo = new THREE.ExtrudeGeometry(shape, {
        extrudePath  : c,
        steps        : steps,
        bevelEnabled : false
      });
    } catch (e) {
      console.warn("ExtrudeGeometry 生成中にエラー:", e);
      geo?.dispose?.();
      return null; 
    }
    const mesh = new THREE.Mesh(geo, new THREE.MeshNormalMaterial());
    if (resultMesh) {
      unionMesh(resultMesh, mesh);
    } else {
      resultMesh = mesh;
    }
  }
  return resultMesh.geometry;
}

function stepsForCurve(c, opts){
  if (c.isLineCurve3) return 6;
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
  return Math.max(6, Math.ceil(len / chordMax));
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
