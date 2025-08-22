import * as THREE from "three";
import { Evaluator, Brush, ADDITION, SUBTRACTION, INTERSECTION } from "three-bvh-csg/index.module";
import { buildEdgeGeometries } from "helpers/board_edge_builders";
//import * as BufferGeometryUtils from "three/examples/jsm/utils/BufferGeometryUtils.js";

// ===== 材質キャッシュ（色や共通質感をまとめる） =====
const materialCache = new Map();
const sharedEvaluator = new Evaluator();
let _csgSeq = 0;
let _csgBusy = false;                  // 再入ガード（任意）

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

// 共通処理： meshA を直接書き換える（geometry だけ差し替え）
function csgReplaceGeometry(meshA, meshB, OP) {
  if (_csgBusy) { console.warn('CSG busy - skipped'); return; }
  _csgBusy = true;
  const label = `CSG.evaluate#${++_csgSeq}:${OP}`;

  const evaluator = sharedEvaluator;   // ※毎回 new しない（後述）
  // ここで console.time 開始
  console.time(label);
  try {
    meshA.updateMatrixWorld( true );
    meshB.updateMatrixWorld( true );

    const A = new Brush(meshA.geometry.clone());
    const B = new Brush(meshB.geometry.clone());

    // ワールド変換を Brush に反映（matrixAutoUpdate を止めて直接使う）
    A.matrixWorld.copy(meshA.matrixWorld)
    B.matrixWorld.copy(meshB.matrixWorld)
    A.matrixAutoUpdate = false
    B.matrixAutoUpdate = false

    // 演算
    const out = evaluator.evaluate(A, B, OP);

    // 旧BVHがあるなら破棄（three-mesh-bvh を使っている場合）
    meshA.geometry?.boundsTree?.dispose?.();
    const oldGeo = meshA.geometry;

    // 差し替え
    meshA.geometry = out.geometry;
    // 必要な境界を先に構築（raycast安定化）
    meshA.geometry.computeBoundingBox();
    meshA.geometry.computeBoundingSphere();
    // 法線は必要時のみ（毎回重いので必要な描画直前に）
    // meshA.geometry.computeVertexNormals();

    // BVH再構築（acceleratedRaycast使用時）
    meshA.geometry.computeBoundsTree?.();

    // out側のmaterialは不要
    out.material?.dispose?.();

    // 旧ジオメトリの破棄は“次フレーム”に遅延（同フレームのraycast競合回避）
    requestAnimationFrame(() => {
      oldGeo?.dispose?.();
      A.geometry?.dispose?.();
      B.geometry?.dispose?.();
    });
  } finally {
    console.timeEnd(label);            // ★ 必ず同じラベルで閉じる
    _csgBusy = false;
  }
}

// A ∪ B（足し算：和）
function unionMesh(meshA, meshB) {
  csgReplaceGeometry(meshA, meshB, ADDITION)
}

// A − B（引き算：差）
function subtractionMesh(meshA, meshB) {
  csgReplaceGeometry(meshA, meshB, SUBTRACTION)
}

// 参考：A ∩ B（共通部分）
//function intersectionMesh(meshA, meshB) {
//  csgReplaceGeometry(meshA, meshB, INTERSECTION)
//}

// ========== メッシュ生成器（葉ノードの具体実装） ==========
// 板
function createBoardMesh(L, W, T) {
  const s = new THREE.Shape()
  s.moveTo(0,0); s.lineTo(L,0); s.lineTo(L,W); s.lineTo(0,W); s.closePath()

  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)

  const m = mat("board", getMeshStandardMaterial(0x7d4712, 0.5))
  const mesh = new THREE.Mesh(geo, m)
  return mesh
}

// 角処理
function createCornerMesh(cornerCtx, pos, L, W, T) {
  if (!cornerCtx.proc || cornerCtx.proc === "NONE") return null;
  const DX = Number(cornerCtx?.dx);
  const DY = Number(cornerCtx?.dy);
  if (!Number.isFinite(DX) || !Number.isFinite(DY) || DX <= 0 || DY <= 0) return null;

  let CX = 0, CY = 0, signX = 1, signY = 1, pix = 0, piy = 0;
  switch (pos) {
    case "tl": CX = 0;  CY = W;  signX = +1; signY = -1; pix = Math.PI / 2; piy = Math.PI; break;
    case "tr": CX = L;  CY = W;  signX = -1; signY = -1; pix = Math.PI / 2; piy = 0; break;
    case "bl": CX = 0;  CY = 0;  signX = +1; signY = +1; pix = -Math.PI / 2; piy = Math.PI; break;
    case "br": CX = L;  CY = 0;  signX = -1; signY = +1; pix = -Math.PI / 2; piy = 0; break;
    default:
      console.warn("unknown pos:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)))
      return null;
  }
  const h = DX > DY ? DY : DX;
  const l = DX > DY ? DX : DY;
  const r = ((l * 2) ** 2) / (8 * h) + h / 2;
  const theta = Math.asin(l / r);
  const cutters = [];
  const s = new THREE.Shape();
  s.moveTo(CX, CY).lineTo(CX + DX * signX, CY);
  switch(cornerCtx.proc) {
    case "BEVEL":
      s.lineTo(CX, CY + DY * signY);
      break;
    case "CHAMFER":
      s.lineTo(CX + DX * signX, CY + DY * signY).lineTo(CX, CY + DY * signY);
      break;
    case "ROUND_R":
      {
        const sx = DX > DY ? CX + signX * DX : CX + signX * r;
        const sy = DX > DY ? CY + signY * r : CY + signY * DY;
        if (DX > DY) {
          s.absarc(sx, sy, r, pix, pix - signX * signY * theta, (signX * signY === 1));
        } else {
          s.absarc(sx, sy, r, piy + signX * signY * theta, piy , (signX * signY === 1));
        }
      }
      break;
    case "INROUND":
      {
        const sx = DX > DY ? CX : CX + signX * (DX - r);
        const sy = DX > DY ? CY + signY * (DY - r) : CY;
        if (DX > DY) {
          s.absarc(sx, sy, r, -pix - signX * signY * theta, -pix, (signX * signY === -1));
        } else {
          s.absarc(sx, sy, r, piy - signX * Math.PI, piy - signX * (Math.PI - signY * theta) , (signX * signY === -1));
        }
      }
      break;
    default:
      console.warn("unknown cornerCtx.prop:", JSON.stringify(cornerCtx.proc), "len=", String(cornerCtx.proc).length,
              "codes=", [...String(cornerCtx.proc)].map(c => c.charCodeAt(0)))
      s = null;
      return null;
  }
  s.closePath();
  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)
  cutters.push(geo);
  // エッジ加工
  const edgeGeos = buildEdgeGeometries(cornerCtx, pos, L, W, T);
  if (edgeGeos) cutters.push(...edgeGeos);

  return cutters
}

// =========== ctx -> meshes 変換（階層を揃える） ===========
export function buildMeshesFromCtx(ctx) {
  if (!ctx) return;
  const meshes = {}
  const L = Number(ctx.length_mm)
  const W = Number(ctx.width_mm)
  const T = Number(ctx.thickness_mm)

  const boardMesh = createBoardMesh(L, W, T)

  // corner（オブジェクト：tl,tr,bl,brなど）
  if (ctx.corner_json && typeof ctx.corner_json === "object") {
    meshes.corner_json = {}
    for (const pos of Object.keys(ctx.corner_json)) {
      const cutters = createCornerMesh(ctx.corner_json[pos], pos, L, W, T)
      if (!cutters) continue;
      const shapeGeo = cutters[0]
      const notchGeo = cutters[1]
      const fillerGeo = cutters[2]
      const cavityGeo = cutters[3]
      const shapeMesh = new THREE.Mesh(shapeGeo, getMeshStandardMaterial(0xff0000, 0.8));
      if (notchGeo) {
        const notchMesh = new THREE.Mesh(notchGeo, getMeshStandardMaterial(0xff0000, 0.8));
        //const fillerMesh = new THREE.Mesh(fillerGeo, getMeshStandardMaterial(0xff0000, 0.8));
        //const cavityMesh = new THREE.Mesh(cavityGeo, getMeshStandardMaterial(0xff0000, 0.8));
        subtractionMesh(boardMesh, notchMesh);
        //unionMesh(boardMesh, fillerMesh);
        //unionMesh(shapeMesh, cavityMesh);
      } else {
        subtractionMesh(boardMesh, shapeMesh);
      }
      const m = mat("corner", getMeshStandardMaterial(0xff0000, 0.8))
      const cornerMesh = new THREE.Mesh(shapeMesh.geometry.clone(), m)
      cornerMesh.name = makeName("corner_json", pos)
      meshes.corner_json[pos] = cornerMesh
    }
  }

  // 最終的な board.geometry が確定した後に
  boardMesh.geometry.computeVertexNormals()
  boardMesh.geometry.computeBoundingSphere()
  boardMesh.geometry.computeBoundingBox()

  meshes.board = boardMesh
  meshes.board.name = makeName("board")

  return meshes
}
