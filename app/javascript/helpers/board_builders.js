import * as THREE from "three";
import { Evaluator, Brush, SUBTRACTION } from "three-bvh-csg/index.module";

// ===== 材質キャッシュ（色や共通質感をまとめる） =====
const materialCache = new Map()
function mat(key, fallback) {
  if (!materialCache.has(key)) materialCache.set(key, fallback)
  return materialCache.get(key)
}

// ===== 名前生成（未指定は省略） =====
function makeName(...parts) {
  return parts.filter(v => v != null && v !== "").join(":")
}

// ===== メッシュ生成器（葉ノードの具体実装） =====
// 板
function createBoardMesh(L, W, T) {
  const s = new THREE.Shape()
  s.moveTo(0,0); s.lineTo(L,0); s.lineTo(L,W); s.lineTo(0,W); s.closePath()

  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)

  const m = mat("board", new THREE.MeshStandardMaterial({ color: 0xffffff, metalness:0, roughness:0.8 }))
  const mesh = new THREE.Mesh(geo, m)
  return mesh
}

// 角処理の例（丸め/面取りなどの分岐をここに）
// tl, tr, bl, br それぞれの ctx（例: { proc: "round", dx: 5, dy: 5 }）を受けてメッシュ生成
function createCornerMesh(cornerCtx, pos, L, W, T) {
  const DX = Number(cornerCtx?.dx);
  const DY = Number(cornerCtx?.dy);
  if (!Number.isFinite(DX) || !Number.isFinite(DY) || DX <= 0 || DY <= 0) return null;
  let CX = 0, CY = 0, signX = 1, signY = 1;
  console.log("DX:", DX, " DY:", DY, " pos:", pos)
  switch (pos) {
    case "tl": CX = 0;  CY = W;  signX = +1; signY = -1; break;
    case "tr": CX = L;  CY = W;  signX = -1; signY = -1; break;
    case "bl": CX = 0;  CY = 0;  signX = +1; signY = +1; break;
    case "br": CX = L;  CY = 0;  signX = -1; signY = +1; break;
    default:
      console.warn("unknown pos:", JSON.stringify(pos), "len=", String(pos).length,
              "codes=", [...String(pos)].map(c => c.charCodeAt(0)))
      return null;
  }
  console.log("DX:", DX, " DY:", DY)
  const s = new THREE.Shape()
  switch(cornerCtx.proc) {
    case "BEVEL":
      s.moveTo(CX, CY)
      .lineTo(CX + DX * signX, CY)
      .lineTo(CX, CY + DY * signY)
      .closePath();
      break;
    case "CHAMFER":
      s.moveTo(CX, CY)
      .lineTo(CX + DX * signX, CY)
      .lineTo(CX + DX * signX, CY + DY * signY)
      .lineTo(CX, CY + DY * signY)
      .closePath();
      break;
    default:
      console.warn("unknown cornerCtx.prop:", JSON.stringify(cornerCtx.proc), "len=", String(cornerCtx.proc).length,
              "codes=", [...String(cornerCtx.proc)].map(c => c.charCodeAt(0)))
      return null;
  }
  console.log("s:", s)
  const geo = new THREE.ExtrudeGeometry(s, { depth: T, bevelEnabled: false })
  // 上面Z=0（Z ∈ [-T,0]）
  geo.translate(0, 0, -T)
  const m = mat("corner", new THREE.MeshStandardMaterial({ color: 0xff0000, metalness:0.2, roughness:0.7 }))
  return new THREE.Mesh(geo, m)
}

// エッジ処理の例（必要に応じて増やす）
function createEdgeMesh(edgeCtx, boardCtx) {
  const len = Number(boardCtx.length_mm)
  const t   = Math.max(2, Number(edgeCtx.width_mm) || 4)
  const geo = new THREE.BoxGeometry(len, t, Math.max(2, Number(boardCtx.thickness_mm) * 0.2))
  const m = mat("edge", new THREE.MeshStandardMaterial({ color: 0x888888 }))
  return new THREE.Mesh(geo, m)
}

// ====== ctx -> meshes 変換（階層を揃える） ======
export function buildMeshesFromCtx(ctx) {
  if (!ctx) return;
  const evaluator = new Evaluator();
  const meshes = {}
  const L = Number(ctx.length_mm)
  const W = Number(ctx.width_mm)
  const T = Number(ctx.thickness_mm)

  const boardMesh = createBoardMesh(L, W, T)

  // corner（オブジェクト：tl,tr,bl,brなど）
  if (ctx.corner_json && typeof ctx.corner_json === "object") {
    meshes.corner = {}
    for (const pos of Object.keys(ctx.corner_json)) {
      const cornerMesh = createCornerMesh(ctx.corner_json[pos], pos, L, W, T)
      if (!cornerMesh) continue;
      cornerMesh.name = makeName("corner", pos)
      meshes.corner[pos] = cornerMesh
      const A = new Brush(boardMesh.geometry.clone(), boardMesh.material);
      const B = new Brush(cornerMesh.geometry.clone(), cornerMesh.material);
      A.matrixWorld.copy(boardMesh.matrixWorld);
      B.matrixWorld.copy(cornerMesh.matrixWorld);
      A.matrixAutoUpdate = B.matrixAutoUpdate = false;
      const out = evaluator.evaluate(
        A,            // A
        B,           // B
        SUBTRACTION            // A − B  (= 引き算)
      );
      const oldGeo = boardMesh.geometry
      boardMesh.geometry = out.geometry
      boardMesh.computeVertexNormals?.();
      // 一時/不要資源の片付け
      out.material?.dispose?.()
      oldGeo.dispose()
      A.geometry?.dispose?.()
      B.geometry?.dispose?.()
    }
  }

  // edge（例：上/下/左/右など任意構造）
  if (ctx.edge && typeof ctx.edge === "object") {
    meshes.edge = {}
    for (const edgeKey of Object.keys(ctx.edge)) {
      const edgeMesh = createEdgeMesh(ctx.edge[edgeKey], ctx.board || {})
      edgeMesh.name = makeName("edge", edgeKey)
      placeEdge(edgeMesh, edgeKey, ctx.board || {})
      meshes.edge[edgeKey] = edgeMesh
    }
  }

  // hole（配列の例）
  if (Array.isArray(ctx.hole)) {
    meshes.hole = []
    const holeMat = mat("hole", new THREE.MeshStandardMaterial({ color: 0x222222 }))
    for (let i = 0; i < ctx.hole.length; i++) {
      const h = ctx.hole[i]
      // 直径d, 深さ=板厚の貫通穴をダミー配置（CSGで引き算するならここでEvaluatorを使う）
      const r = Number(h.diameter_mm) / 2 || 3
      const geo = new THREE.CylinderGeometry(r, r, Number(ctx.board?.thickness_mm) || 10, 32)
      const cyl = new THREE.Mesh(geo, holeMat)
      cyl.name = makeName("hole", String(i))
      // 位置決め（XY=中心、Z=板中心）
      cyl.rotation.x = Math.PI / 2
      cyl.position.set(Number(h.x_mm) || 0, Number(h.y_mm) || 0, -(Number(ctx.board?.thickness_mm) || 10)/2)
      meshes.hole.push(cyl)
    }
  }
  // 最終的な board.geometry が確定した後に
  boardMesh.geometry.computeVertexNormals()
  boardMesh.geometry.computeBoundingSphere()
  boardMesh.geometry.computeBoundingBox()

  meshes.board = boardMesh
  meshes.board.name = makeName("board")

  boardMesh.geometry.dispose()
  boardMesh.material?.dispose?.()
  return meshes
}
