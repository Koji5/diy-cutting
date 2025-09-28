import * as THREE from "three";

import { unionMesh, subtractionMesh } from "helpers/bvh_csg_utils";
import { lumberBuildCtx } from "helpers/lumber_build_ctx";

// ===== 材質キャッシュ（色や共通質感をまとめる） =====
const materialCache = new Map();
const SHARED_CSG_MAT = new THREE.MeshBasicMaterial({ visible: false });

function mat(key, fallback) {
  if (!materialCache.has(key)) materialCache.set(key, fallback)
  return materialCache.get(key)
}

// ===== 名前生成（未指定は省略） =====
function makeName(...parts) {
  return parts.filter(v => v != null && v !== "").join(":")
}

function getMeshStandardMaterial(color, opacity) {
  return new THREE.MeshStandardMaterial({
          color: color,
          transparent: true,   // ← 必須
          opacity: opacity,       // 0(完全透明)〜1(不透明)
          depthWrite: true,   // 透過重なりのチラつき軽減に有効（必要に応じて）
          metalness: 0,
          roughness: 0.9,
          side: THREE.FrontSide, // 両面にしたいなら DoubleSide。ただし透過はアーティファクトが増えやすい
          flatShading: true
        });
}

function createCutOutMesh(cutOutShape, T, type, name, pos){
  const m = 0.1;
  // 切り抜き部分
  if (cutOutShape.curves.length === 0) return null;
  const cutOutGeo = new THREE.ExtrudeGeometry(cutOutShape, { depth: T + m, bevelEnabled: false })
  cutOutGeo.translate(0, 0, - m / 2); // 上面Z=0（Z ∈ [-T,0]）
  cutOutGeo.rotateY(Math.PI/2);
  const material = mat(type, getMeshStandardMaterial(0xff0000, 0.8))
  const cutOutMesh = new THREE.Mesh(cutOutGeo, material);
  cutOutMesh.name = makeName(name, pos);
  return cutOutMesh;
}

export function buildMeshesFromCtx(lumberJSON) {
  if (!lumberJSON) return;
  const ctx = lumberBuildCtx(lumberJSON);
  console.log("ctx:", ctx)
  const meshes = {};
  meshes.side_json = {};
  const lumberShape = new THREE.Shape();
  lumberShape.moveTo(...ctx.moveTo);
  ["bl", "b", "br", "r", "tr", "t", "tl", "l"].forEach(pos=>{
    const posCtx = ctx[pos];
    if (!posCtx) return;
    // 角（コーナー）
    if (posCtx.type === "corner") {
      const processes = posCtx.process;
      console.log("processes:", processes)
      if (processes) {
        const edgePath = new THREE.CurvePath();
        const cutOutShape = new THREE.Shape();
        cutOutShape.moveTo(...posCtx.corner);
        //const p = [new THREE.Vector3(...posCtx.start, 0)];
        for (let i = 0; i < processes.length; i++) {
          const process = processes[i];
          const start = process.start;
          const end = process.end;
          console.log("start:", start," end:", end)
          if (process.type === "line") {
            lumberShape.lineTo(...end);
            cutOutShape.lineTo(...end);
            const p1 = [new THREE.Vector3(0, start[1], -start[0])];
            const p2 = [new THREE.Vector3(0, end[1], -end[0])];
            edgePath.add(new THREE.LineCurve3( p1, p2 ));
          } else if (process.type === "arc") {
            const arc = process.arc;
            lumberShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
            cutOutShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
            const EPS = 1e-6;  
            const startAngle = arc.startAngle - EPS;
            const endAngle = arc.endAngle + EPS;
            const c = new THREE.Vector3(0, arc.center[1], -arc.center[0]);
            edgePath.add(new ArcCurve3_YmZ(c, arc.r, startAngle, endAngle, arc.wise));
          }
        }
        cutOutShape.closePath();
        const cutOutMesh = createCutOutMesh(cutOutShape, ctx.L, "cutOut", "corner_json", pos);
        meshes.side_json[pos] = cutOutMesh;
      }
    // 辺（サイド）
    } else if (posCtx.type === "side") {
      lumberShape.lineTo(...posCtx.end);

    }
  });
  //lumberShape.lineTo(ctx.T, 0);
  //lumberShape.lineTo(ctx.T, ctx.W);
  //lumberShape.lineTo(0, ctx.W);

  lumberShape.closePath();
  const lumberGeo = new THREE.ExtrudeGeometry(lumberShape, { depth: ctx.L, bevelEnabled: false })
  //lumberGeo.translate(0, 0, -ctx.T); // 上面Z=0（Z ∈ [-T,0]）
  lumberGeo.rotateY(Math.PI/2);
  const lumberMaterial = mat("lumber", getMeshStandardMaterial(0x7d4712, 0.5))
  const lumberMesh = new THREE.Mesh(lumberGeo, lumberMaterial);

  // 最終的な lumber.geometry が確定した後に
  lumberMesh.geometry.computeVertexNormals()
  lumberMesh.geometry.computeBoundingSphere()
  lumberMesh.geometry.computeBoundingBox()

  meshes.lumber = lumberMesh
  meshes.lumber.name = makeName("lumber")

  return meshes
}

class ArcCurve3_YmZ extends THREE.Curve {
  constructor(center, radius, startAngle, endAngle, clockwise = false) {
    super();
    this.center = center.clone();
    this.radius = radius;
    this.startAngle = startAngle;
    this.endAngle   = endAngle;

    // 進行方向（時計/反時計）を delta の符号で表現
    let delta = this.endAngle - this.startAngle;
    this.delta = clockwise ? -delta : delta;
  }

  // t ∈ [0,1] を円弧上の点に写像（Y,-Z 平面）
  getPoint(t, target = new THREE.Vector3()) {
    const theta = this.startAngle + this.delta * t;

    // x は中心そのまま（平面は x=const）
    const x = this.center.x;

    // 平面の2軸を Y(=u), -Z(=v) に取るので:
    // y = cy + r * cosθ
    // z = cz - r * sinθ   ← ここが「-Z 固定」のポイント
    const y = this.center.y + this.radius * Math.cos(theta);
    const z = this.center.z - this.radius * Math.sin(theta);

    return target.set(x, y, z);
  }

  // 接ベクトル（単位）
  getTangent(t, target = new THREE.Vector3()) {
    const theta = this.startAngle + this.delta * t;
    // y = cy + r cosθ → dy/dθ = -r sinθ
    // z = cz - r sinθ → dz/dθ = -r cosθ
    // dθ/dt = delta
    const scale = this.delta * this.radius;
    const tx = 0;
    const ty = -Math.sin(theta) * scale;
    const tz = -Math.cos(theta) * scale;
    return target.set(tx, ty, tz).normalize();
  }

  getLength() {
    return Math.abs(this.radius * this.delta);
  }
}
