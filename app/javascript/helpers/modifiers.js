// helpers/modifiers.js
//
// Three.js + three-csg-ts 用ユーティリティ
// --------------------------------------------------------------
import * as THREE from "three";
import { CSG } from "three-csg-ts/CSG";
import * as BufferGeometryUtils
  from "three/examples/jsm/utils/BufferGeometryUtils.js";

// --------------------------------------------------------------
// 1) 平面 Shape を板厚 t で押し出して「板」Geometry を返す
// --------------------------------------------------------------
export function extrudePlate(shape, t) {
  const geo = new THREE.ExtrudeGeometry(shape, {
    depth: t,
    bevelEnabled: false        // 側面は直角
  });
  geo.rotateX(-Math.PI / 2);   // 押し出し方向を Y 軸に
  geo.translate(0, t / 2, 0);  // 板中心を原点に
  return geo;
}

// --------------------------------------------------------------
// 2) 丸穴を CSG で subtract
//    ctx.holes_round = [{ x, z, dia }, …]
// --------------------------------------------------------------
export function applyRoundHoles(baseMesh, ctx) {
  if (!ctx.holes_round?.length) return baseMesh;

  const group = new THREE.Group();
  const hCyl  = ctx.t * 1.1;               // 厚みより少し長く

  ctx.holes_round.forEach(({ x, z, dia }) => {
    const geo = new THREE.CylinderGeometry(dia * 0.5, dia * 0.5, hCyl, 32);
    const m   = new THREE.Mesh(geo, _dummyMat());
    m.position.set(x, 0, z);               // 板中心基準の XZ
    group.add(m);
  });

  let result = CSG.subtract(baseMesh, group);
  result.geometry = _finishGeometry(result.geometry);
  return result;
}

// --------------------------------------------------------------
// 3) 四角穴を CSG で subtract
//    ctx.holes_square = [{ x, z, w, h } …]  // w=X方向, h=Z方向
// --------------------------------------------------------------
export function applySquareHoles(baseMesh, ctx) {
  if (!ctx.holes_square?.length) return baseMesh;

  const group = new THREE.Group();
  const tBox  = ctx.t * 1.1;

  ctx.holes_square.forEach(({ x, z, w, h }) => {
    const geo = new THREE.BoxGeometry(w, tBox, h); // (幅, 高=厚み, 奥行)
    const m   = new THREE.Mesh(geo, _dummyMat());
    m.position.set(x, 0, z);
    group.add(m);
  });

  let result = CSG.subtract(baseMesh, group);
  result.geometry = _finishGeometry(result.geometry);
  return result;
}

// --------------------------------------------------------------
// 4) 面取り（Chamfer）の例
//    ctx.edge_chamfers = [{ side:"left", depth:3 }, …]
// --------------------------------------------------------------
export function applyEdgeChamfer(baseMesh, ctx) {
  if (!ctx.edge_chamfers?.length) return baseMesh;

  const group = new THREE.Group();
  const { w, l, t } = ctx;

  ctx.edge_chamfers.forEach(({ side, depth }) => {
    // depth が 0 か、板の半分以上なら無視
    if (depth <= 0 || depth >= Math.min(w, l) / 2) return;
    const prism = _chamferPrism(depth, (side === "left" || side === "right") ? l : w, t);

    switch (side) {
      case "left":
        prism.rotateY(Math.PI / 2);
        prism.position.set(-w / 2 + depth / 2, 0, 0);
        break;
      case "right":
        prism.rotateY(-Math.PI / 2);
        prism.position.set( w / 2 - depth / 2, 0, 0);
        break;
      case "top":
        prism.position.set(0, 0,  l / 2 - depth / 2);
        break;
      case "bottom":
        prism.rotateY(Math.PI);
        prism.position.set(0, 0, -l / 2 + depth / 2);
        break;
    }
    group.add(prism);
  });

  // ------- プリズムが無ければそのまま返す -------★
  if (group.children.length === 0) return baseMesh;

  const result = CSG.subtract(baseMesh, group);
  result.geometry = _finishGeometry(result.geometry);
  return result;
}

// --------------------------------------------------------------
// 内部 util
// --------------------------------------------------------------
function _dummyMat() {                 // CSG 用の捨てマテリアル
  return new THREE.MeshBasicMaterial();
}

function _finishGeometry(geo) {        // 頂点マージ + 法線再計算
  const merged = BufferGeometryUtils.mergeVertices(geo);
  merged.computeVertexNormals();
  return merged;
}

function _chamferPrism(depth, length, height) {
  // depth: 面取り幅, length: 板の長さ, height: 板厚
  const shape = new THREE.Shape();
  shape.moveTo(0,              -length / 2);
  shape.lineTo(depth,          -length / 2);
  shape.lineTo(0,               length / 2);
  shape.closePath();

  const geo = new THREE.ExtrudeGeometry(shape, {
    depth: height,
    bevelEnabled: false
  });
  geo.rotateX(-Math.PI / 2);
  geo.translate(0, height / 2, 0);
  return new THREE.Mesh(geo, _dummyMat());
}
