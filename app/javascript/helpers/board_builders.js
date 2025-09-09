import * as THREE from "three";

import { createEdgeMesh } from "helpers/board_edge_builders";
import { createHoleMesh } from "helpers/board_hole_builders";
import { unionMesh, subtractionMesh } from "helpers/bvh_csg_utils";
import { boardBuildCtx } from "helpers/board_build_ctx";

//import * as BufferGeometryUtils from "three/examples/jsm/utils/BufferGeometryUtils.js";

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
  cutOutGeo.translate(0, 0, -T - m / 2); // 上面Z=0（Z ∈ [-T,0]）
  const material = mat(type, getMeshStandardMaterial(0xff0000, 0.8))
  const cutOutMesh = new THREE.Mesh(cutOutGeo, material);
  cutOutMesh.name = makeName(name, pos);
  return cutOutMesh;
}

// =========== ctx -> meshes 変換（階層を揃える） ===========
export function buildMeshesFromCtx(boardJSON) {
  if (!boardJSON) return;
  const ctx = boardBuildCtx(boardJSON);
  const edgeCutters = [];
  const meshes = {};
  meshes.side_json = {};
  meshes.corner_json = {};
  meshes.hole_json = {};
  const boardShape = new THREE.Shape();
  boardShape.moveTo(...ctx.moveTo);
  ["bl", "b", "br", "r", "tr", "t", "tl", "l"].forEach(pos=>{
    const posCtx = ctx[pos];
    const process = posCtx.process;
    // 角（コーナー）
    if (posCtx.type === "corner") {
      if (process) {
        const edgePath = new THREE.CurvePath();
        const cutOutShape = new THREE.Shape();
        cutOutShape.moveTo(...posCtx.corner).lineTo(...posCtx.start);
        const p = [new THREE.Vector3(...posCtx.start, 0)];
        if (process.type === "line") {
          for (let i = 1; i < process.line.length; i++) {
            const point = process.line[i];
            boardShape.lineTo(...point);
            cutOutShape.lineTo(...point);
            p.push(new THREE.Vector3(...point, 0));
            edgePath.add(new THREE.LineCurve3( p[i - 1], p[i] ))
          }
        } else if (process.type === "arc") {
          const arc = process.arc;
          boardShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
          cutOutShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, arc.wise);
          edgePath.add(new ArcCurve3(new THREE.Vector3(...arc.center, 0), arc.r, arc.startAngle, arc.endAngle, arc.wise));
        }
        cutOutShape.closePath();
        const cutOutMesh = createCutOutMesh(cutOutShape, ctx.T, "cutOut", "corner_json", pos);
        const edgeMesh = createEdgeMesh(posCtx.edge, ctx.T, edgePath);
        if (edgeMesh){
          edgeCutters.push(edgeMesh);
          const debug = pos + ":corner:" + process.type;
          unionMesh(cutOutMesh, edgeMesh, debug);
        }
        meshes.corner_json[pos] = cutOutMesh;
      }
    // 辺（サイド）
    } else if (posCtx.type === "side") {
      boardShape.lineTo(...posCtx.start);
      let edgeMesh = null, cutOutMesh = null;
      if (posCtx.edge && posCtx.edge !== "NONE") {
        console.log("pos:", pos, " posCtx.edge:", posCtx.edge);
        const edgePath = new THREE.CurvePath();
        const p1 = new THREE.Vector3(...posCtx.start, 0);
        const p2 = new THREE.Vector3(...posCtx.end, 0);
        console.log("posCtx.start:", posCtx.start, " posCtx.end:", posCtx.end);
        edgePath.add(new THREE.LineCurve3( p1, p2 ))
        edgeMesh = createEdgeMesh(posCtx.edge, ctx.T, edgePath);
        edgeCutters.push(edgeMesh);
      }
      if (process) {
        const cutOutShape = new THREE.Shape();
        if (process.type === "line") {
          cutOutShape.moveTo(...process.line[0])
          for (let i = 0; i < process.line.length; i++) {
            const point = process.line[i];
            if (i !== 0) cutOutShape.lineTo(...point);
            boardShape.lineTo(...point);
          }
        } else if (process.type === "arc") {
          cutOutShape.moveTo(...process.startPoint);
          const arc = process.arc;
          boardShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, true);
          cutOutShape.absarc(...arc.center, arc.r, arc.startAngle, arc.endAngle, true);
        }
        cutOutShape.closePath();
        cutOutMesh = createCutOutMesh(cutOutShape, ctx.T, "cutOut", "side_json", pos);
      }
      if (edgeMesh){
        if (cutOutMesh){
          unionMesh(cutOutMesh, edgeMesh);
        } else {
          const m = mat("cutOut", getMeshStandardMaterial(0xff0000, 0.8))
          cutOutMesh = new THREE.Mesh(edgeMesh.geometry, m);
          cutOutMesh.name = makeName("side_json", pos);
        }
      }
      if (cutOutMesh) meshes.side_json[pos] = cutOutMesh;
      boardShape.lineTo(...posCtx.end);
    }
  });
  boardShape.closePath();
  const boardGeo = new THREE.ExtrudeGeometry(boardShape, { depth: ctx.T, bevelEnabled: false })
  boardGeo.translate(0, 0, -ctx.T); // 上面Z=0（Z ∈ [-T,0]）
  const boardMaterial = mat("board", getMeshStandardMaterial(0x7d4712, 0.5))
  const boardMesh = new THREE.Mesh(boardGeo, boardMaterial);

  // エッジを削る
  if (edgeCutters.length) {
    edgeCutters.forEach(edgeCutter => {
      const debug = ":edge:";
      subtractionMesh(boardMesh, edgeCutter, debug);
    });
  }

  // ネジ・ダボ穴
  const holeCtx = ctx["hole"];
  Object.keys(holeCtx).forEach(key => {
    const hole = holeCtx[key];
    if (hole.dx === 0 || hole.dy === 0 || hole.depth === 0) return;
    const geos = createHoleMesh(hole, ctx.T);
    const holeGeo = geos[0];
    const countersinkGeo = geos[1];

    //if (!holeCutter) {
    //  console.warn("ネジ・ダボ穴作成失敗 skip key:", key);
    //  return;
    //} 
    const m = mat("cutOut", getMeshStandardMaterial(0xff0000, 0.8));
    const holeMesh = new THREE.Mesh(holeGeo, m);
    if (countersinkGeo) {
      const countersinkMesh = new THREE.Mesh(countersinkGeo, m);
      unionMesh(holeMesh, countersinkMesh);
    }
    holeMesh.name = makeName("hole_json", key);
    if (holeMesh) meshes.hole_json[key] = holeMesh;
    const debug = ":hole: key:" + key;
    subtractionMesh(boardMesh, holeMesh, debug);
  });

  // 最終的な board.geometry が確定した後に
  boardMesh.geometry.computeVertexNormals()
  boardMesh.geometry.computeBoundingSphere()
  boardMesh.geometry.computeBoundingBox()

  meshes.board = boardMesh
  meshes.board.name = makeName("board")

  return meshes

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
