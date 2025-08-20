import * as THREE from "three";
import { Evaluator, Brush, ADDITION, SUBTRACTION, INTERSECTION } from "three-bvh-csg/index.module";
import * as BufferGeometryUtils from 'three/examples/jsm/utils/BufferGeometryUtils.js';

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

  const A = new Brush(prepForCSG(meshA.geometry.clone()), meshA.material);
  const B = new Brush(prepForCSG(meshB.geometry.clone()), meshB.material);

  // ワールド変換を Brush に反映（matrixAutoUpdate を止めて直接使う）
  A.matrixWorld.copy(meshA.matrixWorld)
  B.matrixWorld.copy(meshB.matrixWorld)
  A.matrixAutoUpdate = false
  B.matrixAutoUpdate = false

  // 演算
  const out = evaluator.evaluate(A, B, OP);

  // meshA の geometry を差し替え（material は meshA の既存を維持）
  const oldGeo = meshA.geometry
  meshA.geometry = out.geometry

  // 法線の再計算
  meshA.geometry.computeVertexNormals()


  // out 側の material は不要なので破棄（meshA.material は維持）
  out.material?.dispose?.()

  // 一時/不要リソースの破棄
  oldGeo?.dispose?.()
  A.geometry?.dispose?.()
  B.geometry?.dispose?.()
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
function intersectionMesh(meshA, meshB) {
  csgReplaceGeometry(meshA, meshB, INTERSECTION)
}

function prepForCSG(geom) {
  // 溶接して index 付与（重複頂点を統合）
  let g = BufferGeometryUtils.mergeVertices(geom, 1e-6);

  // groups を単一化（マルチマテリアルでないなら）
  const idx = g.getIndex();
  if (idx && idx.count > 0) {
    g.clearGroups();
    g.addGroup(0, idx.count, 0);
  }

  g.computeVertexNormals();
  return g;
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

// 角処理の例（丸め/面取りなどの分岐をここに）
// tl, tr, bl, br それぞれの ctx（例: { proc: "round", dx: 5, dy: 5 }）を受けてメッシュ生成
function createCornerMesh(cornerCtx, pos, L, W, T) {
  const DX = Number(cornerCtx?.dx);
  const DY = Number(cornerCtx?.dy);
  if (!Number.isFinite(DX) || !Number.isFinite(DY) || DX <= 0 || DY <= 0) return null;

  const edgePath = new THREE.CurvePath();
  const cutterMeshes = [];
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
  const s = new THREE.Shape();
  s.moveTo(CX, CY).lineTo(CX + DX * signX, CY);
  const p1 = new THREE.Vector3(CX + DX * signX, CY, 0);
  switch(cornerCtx.proc) {
    case "BEVEL":
      {
        s.lineTo(CX, CY + DY * signY);
        const p2 = new THREE.Vector3(CX, CY + DY * signY, 0);
        edgePath.add( new THREE.LineCurve3( p1, p2 ));
      }
      break;
    case "CHAMFER":
      {
        s.lineTo(CX + DX * signX, CY + DY * signY)
        .lineTo(CX, CY + DY * signY);
        const p2 = new THREE.Vector3(CX + DX * signX, CY + DY * signY, 0);
        const p3 = new THREE.Vector3(CX, CY + DY * signY, 0);
        edgePath.add( new THREE.LineCurve3( p1, p2 ));
        edgePath.add( new THREE.LineCurve3( p2, p3 ));
      }
      break;
    case "ROUND_R":
      {
        const sx = DX > DY ? CX + signX * DX : CX + signX * r;
        const sy = DX > DY ? CY + signY * r : CY + signY * DY;
        const center = new THREE.Vector3(sx, sy, 0);
        let arc3;
        if (DX > DY) {
          s.absarc(sx, sy, r, pix, pix - signX * signY * theta, (signX * signY === 1));
          arc3 = new ArcCurve3( center, r, pix, pix - signX * signY * theta, (signX * signY === 1));
        } else {
          s.absarc(sx, sy, r, piy + signX * signY * theta, piy , (signX * signY === 1));
          arc3 = new ArcCurve3( center, r, piy + signX * signY * theta, piy, (signX * signY === 1));
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
          s.absarc(sx, sy, r, -pix - signX * signY * theta, -pix, (signX * signY === -1));
          arc3 = new ArcCurve3( center, r, -pix - signX * signY * theta, -pix, (signX * signY === -1));
        } else {
          s.absarc(sx, sy, r, piy - signX * Math.PI, piy - signX * (Math.PI - signY * theta) , (signX * signY === -1));
          arc3 = new ArcCurve3( center, r, piy - signX * Math.PI, piy - signX * (Math.PI - signY * theta), (signX * signY === -1));
        }
        edgePath.add(arc3);
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
  const shapeMesh = new THREE.Mesh(geo, getMeshStandardMaterial(0xff0000, 0.8));
  cutterMeshes.push(shapeMesh);
  // エッジ加工
  const edgeGeo = createEdgeGeometry(cornerCtx.edge, T, edgePath);
  if (edgeGeo) {
    const edgeMesh = new THREE.Mesh(edgeGeo, getMeshStandardMaterial(0xff0000, 0.8));
    cutterMeshes.push(edgeMesh);
  }
  return cutterMeshes
}

// =========== ctx -> meshes 変換（階層を揃える） ===========
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
    meshes.corner_json = {}
    for (const pos of Object.keys(ctx.corner_json)) {
      const cutterMeshes = createCornerMesh(ctx.corner_json[pos], pos, L, W, T)
      if (!cutterMeshes) continue;
      const shapeMesh = cutterMeshes[0]
      const edgeMesh = cutterMeshes[1]
      subtractionMesh(boardMesh, shapeMesh)
      if (edgeMesh) {
        subtractionMesh(boardMesh, edgeMesh)
        unionMesh(shapeMesh, edgeMesh)
      }
      const m = mat("corner", getMeshStandardMaterial(0xff0000, 0.8))
      const cornerMesh = new THREE.Mesh(shapeMesh.geometry, m)
      cornerMesh.name = makeName("corner_json", pos)
      meshes.corner_json[pos] = cornerMesh
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

/* ---------- 1. 断面プロファイル ---------- */
function moveToStart(s, y) {
  s.moveTo(1, 1).lineTo(1, y).lineTo(0, y);
}
function moveToEnd(s, y, T) {
  s.lineTo(-T - 1, y).lineTo(-T - 1, 1).closePath();
}
function edgeProfile(code, T) {
  const s = new THREE.Shape();
  switch (code) {
    case "CHAMF_BTH": { // 上下糸面
      moveToStart(s, -1);
      s.lineTo(-1, 0).lineTo(-T + 1, 0).lineTo(-T, -1);
      moveToEnd(s, -1, T);
      break;
    }
    case "BULLNOSE": { // ボーズ面
      const R = T / 2;
      s.moveTo(0, 0);                               // 上端
s.lineTo(0, R).lineTo(R, R)
      s.closePath();
      break;
    }
    case "CHM5MM": { // 上下5mm面
      moveToStart(s, -5);
      s.lineTo(-5, 0).lineTo(-T + 5, 0).lineTo(-T, -5);
      moveToEnd(s, -5, T);
      break;
    }
    case "CHM10MM": { // 上下10mm面
      moveToStart(s, -10);
      s.lineTo(-10, 0).lineTo(-T + 10, 0).lineTo(-T, -10);
      moveToEnd(s, -10, T);
      break;
    }
    case "R5ROUND": { // 上下5R面
      moveToStart(s, -5);
      s.absarc(-5, -5, 5, 0, Math.PI / 2, false);
      s.lineTo(-T + 5, 0);
      s.absarc(-T + 5, -5, 5, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -5, T);
      break;
    }
    case "R10ROUND": { // 上下10R面
      moveToStart(s, -10);
      s.absarc(-10, -10, 10, 0, Math.PI / 2, false);
      s.lineTo(-T + 10, 0);
      s.absarc(-T + 10, -10, 10, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -10, T);
      break;
    }
    case "COVE": { // ギンナン面
      moveToStart(s, 0);
      s.lineTo(-T + 9, 0).lineTo(-T + 9, -3);
      s.absarc(-T + 9, -9, 6, Math.PI / 2, Math.PI, false);
      moveToEnd(s, -9, T);
      break;
    }
    case "OGEE": { // 船底面
      moveToStart(s, -T + 10 / Math.SQRT2);
      s.lineTo(-T + 5 + 5 / Math.SQRT2, -5 + 5 / Math.SQRT2);
      s.absarc(-T + 5, -5, 5, Math.PI / 4, Math.PI, false);
      moveToEnd(s, -5, T);
      break;
    }
  }
  return s;
}

function createEdgeGeometry(code, T, edgePath) {
  if (!code || code === "NONE") return null;
  if (!edgePath?.curves?.length) return null;
  if (edgePath.getLength() === 0) return null;
  // エッジ加工
  const profile = edgeProfile(code, T);

  function stepsForCurve(c) {
    if (c.isLineCurve3)          return 1;                 // 直線は 1
    const len  = c.getLength();                            // mm
    const unit = c.isCubicBezierCurve3 ? 2 : 3;            // ベジエ 2 mm, それ以外 3 mm
    return Math.max(1, Math.ceil(len / unit));
  }
  const steps = edgePath.curves.reduce(
    (sum, c) => sum + stepsForCurve(c), 0
  );
  const clampedSteps = Math.max(2, Math.min(200, steps));

  let edgeGeo = null;
  try {
    edgeGeo = new THREE.ExtrudeGeometry(profile, {
      extrudePath  : edgePath,
      steps        : clampedSteps,
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
    return null;                   // ★
  }
  return edgeGeo;
}
