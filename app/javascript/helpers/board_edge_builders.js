import * as THREE from "three";
import { unionMesh } from "helpers/bvh_csg_utils";

const SHARED_CSG_MAT = new THREE.MeshBasicMaterial({ visible: false });

export function createEdgeMesh(code, T, edgePath){
  const geo = buildCavityGeometry(code, T, edgePath);
  if (geo) {
    if (!geo.attributes.normal) {
      geo.computeVertexNormals();
    }
    return new THREE.Mesh(geo, SHARED_CSG_MAT);
  }
  return null;
}

function buildCavityGeometry(code, T, edgePath){
  // マージン
  const m = -0.08;
  const s = new THREE.Shape();
  s.moveTo(0, m);
  switch (code) {
    case "CHAMF_BTH":
      s.lineTo(T, m).lineTo(T, 1).lineTo(T - 1, 0).lineTo(1, 0).lineTo(0, 1);
      break;
    case "BULLNOSE":  // ボーズ面
      s.lineTo(T, m).lineTo(T, T / 2 - m);
      s.absarc(T / 2, T / 2 - m, T / 2, 0, Math.PI, true);
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
    case "OGEE":
      { // 船底面
        const l = T - 10 / Math.sqrt(2);
        s.lineTo(0, 5);
        s.absarc(5, 5, 5, Math.PI, -Math.PI / 4, false);
        s.lineTo(T, l).lineTo(T, m);
      }
      break;
    default:
      return null;
  }
  s.closePath();
  return extrudeAlongPath(s, edgePath);
}

function extrudeAlongPath(shape, edgePath) {
  // ───────────────────────────────────────────────────────────────
  // 曲線離散化パラメータ（※単位はシーンのワールド単位。mm 系なら mm）
  //   - s:       サジッタ（弦と弧の最大ふくらみ）許容値。小さいほど滑らか・重い
  //   - maxDeg:  1 セグメントあたりの中心角の上限（度）。小さいほど滑らか・重い
  //   - maxChord:1 セグメントの弦長の上限。小さいほど滑らか・重い
  //
  // 実際の分割角 dθ は「dSag（サジッタ制約）・dDeg（角度制約）・dChord（弦長制約）」の最小を採用。
  // つまり 3 つの条件すべてを満たすように刻みを決定します。
  // ───────────────────────────────────────────────────────────────
  // const fillerOpts = { s: 0.06, maxDeg: 2, maxChord: 2.5 };
  const fillerOpts = { s:0.15, maxDeg:2, maxChord:2.5 };

  let resultMesh = null;
  for (const c of edgePath.curves) {
    const steps = THREE.MathUtils.clamp(stepsForCurve(c, fillerOpts), 6, 80);
    let geo = null;
    console.log("steps", steps)
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
