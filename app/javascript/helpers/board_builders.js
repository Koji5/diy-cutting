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

  const m = mat("board", new THREE.MeshStandardMaterial({ color: 0xffffff, metalness:0.2, roughness:0.7 }))
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
      //  boardMesh.updateMatrixWorld( true );
      //  cornerMesh.updateMatrixWorld( true );
      const A = new Brush(boardMesh.geometry.clone(), boardMesh.material);
      const B = new Brush(cornerMesh.geometry.clone(), cornerMesh.material);
      A.matrixWorld.copy(boardMesh.matrixWorld );
      B.matrixWorld.copy(cornerMesh.matrixWorld );
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
  // 1) 退化除去 → 頂点マージ
  const tmp   = stripDegenerateTriangles(boardMesh.geometry);
  const clean = weldToIndexed(tmp, 1e-4);  // 必要なら 1e-3 まで上げる
  tmp.dispose();

  // 進捗ログ（ここが true になれば OK）
  console.log('after weld -> indexed?', !!clean.index,
              'uniq verts', clean.getAttribute('position')?.count,
              'index tris', clean.index?.count/3);

  boardMesh.geometry.dispose();
  boardMesh.geometry = clean;              // ← 置き換え
  boardMesh.geometry.computeVertexNormals();

  // 4) 置き換え後の boardMesh.geometry から Edges を作る
  const eg = new THREE.EdgesGeometry(boardMesh.geometry, 30); // 20〜40°で調整可
  console.log('edges posCount', eg.getAttribute('position')?.count);
  clean.dispose();

  const edges = new THREE.LineSegments(
    eg,
    new THREE.LineBasicMaterial({ color: 0x333333, depthTest: true, depthWrite: false })
  );
  boardMesh.renderOrder = 10;
  edges.renderOrder     = 11;
  boardMesh.add(edges);

  const g = boardMesh.geometry
  // debug
  console.log('indexed?', !!g.index, 'posCount', g.getAttribute('position')?.count);
  const egTest = new THREE.EdgesGeometry(g, 30);
  console.log('edges posCount', egTest.getAttribute('position')?.count);
  egTest.dispose();
  g.computeVertexNormals()
  g.computeBoundingSphere()
  g.computeBoundingBox()
  meshes.board = boardMesh
  meshes.board.geometry = g
  meshes.board.name = makeName("board")

  g.dispose()
  boardMesh.geometry.dispose()
  boardMesh.material?.dispose?.()
  return meshes
}

//function stripDegenerateTriangles(geom, eps = 1e-12) {
//  const src = geom.index ? geom.toNonIndexed() : geom.clone();
//  const pos = src.getAttribute('position');
//  if (!pos) return src;

//  const out = [];
//  const a = new THREE.Vector3(), b = new THREE.Vector3(), c = new THREE.Vector3();
//  for (let i = 0; i < pos.count; i += 3) {
//    a.fromBufferAttribute(pos, i+0);
//    b.fromBufferAttribute(pos, i+1);
//    c.fromBufferAttribute(pos, i+2);
//    const area2 = b.clone().sub(a).cross(c.clone().sub(a)).lengthSq();
//    if (Number.isFinite(area2) && area2 > eps) {
//      out.push(a.x,a.y,a.z, b.x,b.y,b.z, c.x,c.y,c.z);
//    }
//  }
//  const G = new THREE.BufferGeometry();
//  if (out.length) G.setAttribute('position', new THREE.Float32BufferAttribute(out, 3));
//  src.dispose();
//  return G;
//}

function mergeVerticesForEdges(geom, tol = 1e-4) { // ★ tol を大きめに
  // 1) 非インデックス化（三角順に並ぶ）
  const src = geom.index ? geom.toNonIndexed() : geom.clone();
  const pos = src.getAttribute('position');
  if (!pos || pos.count === 0) return src;

  const keyScale = 1 / tol;
  const map = new Map();   // 量子化座標 → 新index
  const uniq = [];
  const index = [];

  for (let i = 0; i < pos.count; i++) {
    const x = pos.getX(i), y = pos.getY(i), z = pos.getZ(i);
    const k = `${Math.round(x*keyScale)},${Math.round(y*keyScale)},${Math.round(z*keyScale)}`;
    let idx = map.get(k);
    if (idx === undefined) {
      idx = (uniq.length / 3);
      uniq.push(x, y, z);
      map.set(k, idx);
    }
    index.push(idx);
  }

  const G = new THREE.BufferGeometry();
  G.setAttribute('position', new THREE.Float32BufferAttribute(new Float32Array(uniq), 3));
  const IndexArray = (uniq.length/3 > 65535) ? Uint32Array : Uint16Array;
  G.setIndex(new THREE.BufferAttribute(new IndexArray(index), 1));
  G.clearGroups();
  G.computeBoundingSphere();
  G.computeBoundingBox();

  src.dispose();
  return G;
}

function makeEdgesSafeForBoard(boardMesh) {
  // 退化を除去 → 頂点共有化（tolは mm スケールなら 1e-4 〜 1e-3 を推奨）
  const tmp   = stripDegenerateTriangles(boardMesh.geometry);
  const clean = mergeVerticesForEdges(tmp, 1e-4);
  tmp.dispose();

  // 進捗ログ（★ここが重要）
  console.log('clean indexed?', !!clean.index,
              'uniq verts', clean.getAttribute('position')?.count,
              'triangles', clean.index?.count/3);

  const eg = new THREE.EdgesGeometry(clean, 30); // 20〜40°で調整可
  clean.dispose();

  const ep = eg.getAttribute('position');
  if (!ep || ep.count === 0) { eg.dispose(); return null; }

  const edges = new THREE.LineSegments(
    eg,
    new THREE.LineBasicMaterial({ color: 0x333333, depthTest: true, depthWrite: false })
  );
  edges.renderOrder = (boardMesh.renderOrder ?? 0) + 1;
  return edges;
}
// 1) 退化三角形を除去（おまじない）
function stripDegenerateTriangles(geom, eps = 1e-12) {
  const src = geom.index ? geom.toNonIndexed() : geom.clone();
  const pos = src.getAttribute('position');
  if (!pos) return src;

  const out = [];
  const a = new THREE.Vector3(), b = new THREE.Vector3(), c = new THREE.Vector3();
  for (let i = 0; i < pos.count; i += 3) {
    a.fromBufferAttribute(pos, i+0);
    b.fromBufferAttribute(pos, i+1);
    c.fromBufferAttribute(pos, i+2);
    const area2 = b.clone().sub(a).cross(c.clone().sub(a)).lengthSq();
    if (Number.isFinite(area2) && area2 > eps) {
      out.push(a.x,a.y,a.z, b.x,b.y,b.z, c.x,c.y,c.z);
    }
  }
  const G = new THREE.BufferGeometry();
  if (out.length) G.setAttribute('position', new THREE.Float32BufferAttribute(out, 3));
  src.dispose();
  return G;
}

// 2) 頂点溶接して index を作る（tol は mm スケールなら 1e-4〜1e-3）
function weldToIndexed(geom, tol = 1e-4) {
  const src = geom.index ? geom.toNonIndexed() : geom.clone();
  const pos = src.getAttribute('position');
  if (!pos || pos.count === 0) return src;

  const keyScale = 1 / tol;
  const map = new Map();
  const uniq = [];
  const index = [];

  for (let i = 0; i < pos.count; i++) {
    const x = pos.getX(i), y = pos.getY(i), z = pos.getZ(i);
    const k = `${Math.round(x*keyScale)},${Math.round(y*keyScale)},${Math.round(z*keyScale)}`;
    let idx = map.get(k);
    if (idx === undefined) {
      idx = (uniq.length / 3);
      uniq.push(x, y, z);
      map.set(k, idx);
    }
    index.push(idx);
  }

  const G = new THREE.BufferGeometry();
  G.setAttribute('position', new THREE.Float32BufferAttribute(new Float32Array(uniq), 3));
  const IndexArray = (uniq.length/3 > 65535) ? Uint32Array : Uint16Array;
  G.setIndex(new THREE.BufferAttribute(new IndexArray(index), 1));
  G.clearGroups();
  G.computeBoundingSphere();
  G.computeBoundingBox();
  src.dispose();
  return G;
}