import * as THREE from "three";

import { createEdgeGeo } from "helpers/lumber_edge_builders";
import { unionMesh, subtractionMesh } from "helpers/bvh_csg_utils";
import { lumberBuildCtx } from "helpers/lumber_build_ctx";

// ===== 材質キャッシュ（色や共通質感をまとめる） =====
const materialCache = new Map();

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
  meshes.side_json["c"] = {};
  const c = meshes.side_json["c"];
  const lumberShape = new THREE.Shape();
  lumberShape.moveTo(...ctx.moveTo);
  const edgePath = new THREE.CurvePath();
  ["bl", "b", "br", "r", "tr", "t", "tl", "l"].forEach(pos=>{
    const posCtx = ctx[pos];
    if (!posCtx) return;
    // 角（コーナー）
    if (posCtx.type === "corner") {
      const processes = posCtx.process;
      console.log("processes:", processes)
      if (processes) {
        const cutOutShape = new THREE.Shape();
        cutOutShape.moveTo(...posCtx.corner);
        for (let i = 0; i < processes.length; i++) {
          const process = processes[i];
          const start = process.start;
          const end = process.end;
          console.log("start:", start," end:", end)
          if (process.type === "line") {
            lumberShape.lineTo(...end);
            cutOutShape.lineTo(...start);
            cutOutShape.lineTo(...end);
            const p1 = new THREE.Vector3(...start, 0);
            const p2 = new THREE.Vector3(...end, 0);
            edgePath.add(new THREE.LineCurve3( p1, p2 ));
          } else if (process.type === "arc") {
            const arc = process.arc;
            lumberShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
            cutOutShape.lineTo(...start);
            cutOutShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
            const c = new THREE.Vector3(...arc.center, 0);
            edgePath.add(new ArcCurve3(c, arc.r, arc.startAngle, arc.endAngle, arc.wise));
          }
        }
        cutOutShape.closePath();
        const cutOutMesh = createCutOutMesh(cutOutShape, ctx.L, "cutOut", "corner_json", pos);
        c[pos] = cutOutMesh;
      }
    // 辺（サイド）
    } else if (posCtx.type === "side") {
      const start = posCtx.start;
      const end = posCtx.end;
      const p1 = new THREE.Vector3(...start, 0);
      const p2 = new THREE.Vector3(...end, 0);
      edgePath.add(new THREE.LineCurve3( p1, p2 ));
      lumberShape.lineTo(...posCtx.end);
    }
  });

  lumberShape.closePath();
  const lumberGeo = new THREE.ExtrudeGeometry(lumberShape, { depth: ctx.L, bevelEnabled: false })
  lumberGeo.rotateY(Math.PI/2);
  const lumberMaterial = mat("lumber", getMeshStandardMaterial(0x7d4712, 0.5))
  const lumberMesh = new THREE.Mesh(lumberGeo, lumberMaterial);

  // エッジを削る
  ["l","r"].forEach(pos=>{
    const sideJSON = ctx.sideJSON[pos];
    if (!sideJSON || sideJSON.proc === "NONE") return;
    let resultMesh = null;
    const cutOutGeos = createEdgeGeo(sideJSON.proc, edgePath);
    cutOutGeos.forEach(geo=>{
      if (pos === "l") {
        geo.rotateY(Math.PI/2);
      } else {
        geo.rotateY(-Math.PI/2);
        geo.translate(ctx.L, 0, -ctx.T);
      }
      const mesh = new THREE.Mesh(geo, new THREE.MeshNormalMaterial());
      const subMesh = mesh.clone();
      if (resultMesh) {
        unionMesh(resultMesh, mesh);
      } else {
        resultMesh = mesh;
      }
      const debug = ":edge:" + pos + ":";
      subtractionMesh(lumberMesh, subMesh, debug);
    });
    if (!resultMesh) return;
    const material = mat("cutOut", getMeshStandardMaterial(0xff0000, 0.8))
    const cutOutMesh = new THREE.Mesh(resultMesh.geometry, material);
    cutOutMesh.name = makeName("side_json", pos);
    meshes.side_json[pos] = cutOutMesh;
  });

  // 最終的な lumber.geometry が確定した後に
  lumberMesh.geometry.computeVertexNormals()
  lumberMesh.geometry.computeBoundingSphere()
  lumberMesh.geometry.computeBoundingBox()

  meshes.lumber = lumberMesh
  meshes.lumber.name = makeName("lumber")

  return meshes
}

class ArcCurve3 extends THREE.Curve {
  constructor(center, radius, startAngle, endAngle, clockwise = false) {
    super();
    this.center = center.clone();
    this.radius = radius;
    this.startAngle = startAngle;
    this.endAngle   = endAngle;
    this.clockwise  = clockwise;
  }

  // 2πで [0, 2π) に正規化
  static _mod2pi(a) {
    const TAU = Math.PI * 2;
    return ((a % TAU) + TAU) % TAU;
  }

  // 方向に応じた掃過角（span）を決定：CCWは +[0..2π)、CWは -[0..2π)
  _span() {
    const TAU = Math.PI * 2;
    const ccw = ArcCurve3._mod2pi(this.endAngle - this.startAngle);     // 0..2π
    if (!this.clockwise) return ccw;                                    // CCW: +短経路
    const cw = ArcCurve3._mod2pi(this.startAngle - this.endAngle);      // 0..2π
    return cw === 0 ? -TAU : -cw;  // start==end のとき CWなら -2π にしたい場合
  }

  getPoint(t, target = new THREE.Vector3()) {
    const a = this.startAngle + t * this._span();
    target.set(
      this.center.x + this.radius * Math.cos(a),
      this.center.y + this.radius * Math.sin(a),
      0
    );
    return target;
  }

  // Extrude 用に接線も定義（任意だが安定する）
  getTangent(t, target = new THREE.Vector3()) {
    const span = this._span();
    const a = this.startAngle + t * span;
    // d/dt [x,y] = [-R sin(a)*span, R cos(a)*span]
    const dx = -this.radius * Math.sin(a) * span;
    const dy =  this.radius * Math.cos(a) * span;
    target.set(dx, dy, 0);
    return target.normalize();
  }
}
