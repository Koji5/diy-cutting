import * as THREE from "three";

import { buildCornerEdgeGeometries } from "helpers/board_edge_builders";
import { unionMesh, subtractionMesh } from "helpers/bvh_csg_utils";

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

// マージ処理
function margeCornerMesh(boardMesh, cutters){
  const shapeGeo = cutters[0]
  const notchGeo = cutters[1]
  const cavityGeo = cutters[2]
  const fillerGeo = cutters[3]
  const shapeMesh = new THREE.Mesh(shapeGeo, SHARED_CSG_MAT);
  if (notchGeo) {
    const notchMesh = new THREE.Mesh(notchGeo, SHARED_CSG_MAT);
    const cavityMesh = new THREE.Mesh(cavityGeo, SHARED_CSG_MAT);
    const fillerMesh = new THREE.Mesh(fillerGeo, SHARED_CSG_MAT);
    subtractionMesh(boardMesh, notchMesh);
    unionMesh(shapeMesh, cavityMesh);
    unionMesh(boardMesh, fillerMesh);
  } else {
    subtractionMesh(boardMesh, shapeMesh);
  }
  return shapeMesh;
}
function margeSideMesh(boardMesh, cutters){
  const shapeGeo = cutters[0]
  const cavityGeo = cutters[1]
  const shapeMesh = new THREE.Mesh(shapeGeo, SHARED_CSG_MAT);
  if (cavityGeo) {
    const cavityMesh = new THREE.Mesh(cavityGeo, SHARED_CSG_MAT);
    subtractionMesh(boardMesh, cavityMesh);
    subtractionMesh(boardMesh, shapeMesh);
    unionMesh(shapeMesh, cavityMesh);
  } else {
    subtractionMesh(boardMesh, shapeMesh);
  }
  return shapeMesh;
}
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
  const edgeGeos = buildCornerEdgeGeometries(cornerCtx, pos, L, W, T);
  if (edgeGeos) cutters.push(...edgeGeos);

  return cutters
}

// 辺処理
function createSideMesh(sideCtx, pos, L, W, T, DXY) {
  if (!sideCtx.proc || sideCtx.proc === "NONE") return null;
  const SD = Number(sideCtx?.sd);
  const SW = Number(sideCtx?.sw);
  const SP = Number(sideCtx?.sp);
  if (!Number.isFinite(SD) || !Number.isFinite(SW) || SD <= 0 || SW <= 0) return null;

  const r = (SD ** 2) / (8 * SW) + SW / 2;
  const theta = Math.asin(SD / (2 * r));
  const d = r * Math.cos(theta);

  let sx1 = 0, sx2 = 0, sx3 = 0, sx4 = 0, pi = 0, sy1 = 0, sy2 = 0, sy3 = 0, sy4 = 0, sx = 0, sy = 0;
  switch (pos) {
    case "t":
//      startX = DXY.tl.dx;  startY = W;
      sx1 = SP - SD / 2; sy1 = W;
      sx2 = SP - SD / 2; sy2 = W - SW;
      sx3 = SP + SD / 2; sy3 = W - SW;
      sx4 = SP + SD / 2; sy4 = W;
//      endX = L - DXY.tr.dx; endY = W;
      sx = SP; sy = W + d;
      pi = -Math.PI / 2;
      break;
    case "r":
      sx1 = L; sy1 = SP + SD / 2;
      sx2 = L - SW; sy2 = SP + SD / 2;
      sx3 = L - SW; sy3 = SP - SD / 2;
      sx4 = L; sy4 = SP - SD / 2;
      sx = L + d; sy = SP;
      pi = Math.PI;
      break;
    case "b":
      sx1 = SP + SD / 2; sy1 = 0;
      sx2 = SP + SD / 2; sy2 = SW;
      sx3 = SP - SD / 2; sy3 = SW;
      sx4 = SP - SD / 2; sy4 = 0;
      sx = SP; sy = -d;
      pi = Math.PI / 2;
      break;
    case "l":
      sx1 = 0; sy1 = SP - SD / 2;
      sx2 = SW; sy2 = SP - SD / 2;
      sx3 = SW; sy3 = SP + SD / 2;
      sx4 = 0; sy4 = SP + SD / 2;
      sx = -d; sy = SP;
      pi = 0;
      break;
    default:
      console.warn("unknown pos:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)))
      return null;
  }
  const s = new THREE.Shape();
  s.moveTo(sx1,  sy1);
  if (sideCtx.proc === "SQUARE") {
    s.lineTo(sx2,  sy2).lineTo(sx3,  sy3).lineTo(sx4,  sy4);
  } else if (sideCtx.proc === "ROUND") {
    if (SD / 2 < SW){
      console.warn("SD / 2 < SW pos:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0))), " proc:", JSON.stringify(sideCtx.proc), "len=", String(sideCtx.proc).length,
              "codes=", [...String(sideCtx.proc)].map(c => c.charCodeAt(0))
      return null;
    }
    s.absarc(sx, sy, r, pi - theta, pi + theta, false);
  } else {
    console.warn("unknown pos:", JSON.stringify(pos), "len=", String(pos).length,
            "codes=", [...String(pos)].map(c => c.charCodeAt(0))), " proc:", JSON.stringify(sideCtx.proc), "len=", String(sideCtx.proc).length,
            "codes=", [...String(sideCtx.proc)].map(c => c.charCodeAt(0))
    return null;
  }
  s.closePath();
  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)
  const cutters = [];
  cutters.push(geo);
  // エッジ加工
  //const edgeGeos = buildSideEdgeGeometries(sideCtx, pos, L, W, T, DXY);
  //if (edgeGeos) cutters.push(...edgeGeos);

  return cutters
}


// =========== ctx -> meshes 変換（階層を揃える） ===========
export function buildMeshesFromCtx(ctx) {
  if (!ctx) return;
  const meshes = {}
  const L = Number(ctx.length_mm)
  const W = Number(ctx.width_mm)
  const T = Number(ctx.thickness_mm)
  const DXY = {}

  const boardMesh = createBoardMesh(L, W, T)

  // corner（オブジェクト：tl,tr,bl,brなど）
  if (ctx.corner_json && typeof ctx.corner_json === "object") {
    meshes.corner_json = {}
    for (const pos of Object.keys(ctx.corner_json)) {
      DXY[pos] = {
        dx: Number(ctx.corner_json[pos]?.dx ?? 0),
        dy: Number(ctx.corner_json[pos]?.dy ?? 0),
      }
      const cutters = createCornerMesh(ctx.corner_json[pos], pos, L, W, T)
      if (!cutters) continue;
      const shapeMesh = margeCornerMesh(boardMesh, cutters);
      const m = mat("corner", getMeshStandardMaterial(0xff0000, 0.8))
      const cornerMesh = new THREE.Mesh(shapeMesh.geometry.clone(), m)
      cornerMesh.name = makeName("corner_json", pos)
      meshes.corner_json[pos] = cornerMesh
    }
  }

  // side (t, r, b, l)
  if (ctx.side_json && typeof ctx.side_json === "object") {
    meshes.side_json = {}
    for (const pos of Object.keys(ctx.side_json)) {
      const cutters = createSideMesh(ctx.side_json[pos], pos, L, W, T, DXY)
      if (!cutters) continue;
      const shapeMesh = margeSideMesh(boardMesh, cutters);
      const m = mat("corner", getMeshStandardMaterial(0xff0000, 0.8))
      const sideMesh = new THREE.Mesh(shapeMesh.geometry.clone(), m)
      sideMesh.name = makeName("side_json", pos)
      meshes.side_json[pos] = sideMesh
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
